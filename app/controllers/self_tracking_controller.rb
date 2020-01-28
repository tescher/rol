include ApplicationHelper
include WaiversHelper

class SelfTrackingController < ApplicationController
  before_action :has_valid_workday, except: [ :launch ]
  before_action :logged_in_user, only: [:launch]

  def has_valid_workday
    if !session[:self_tracking_workday_id].present?
      flash[:danger] = "No workday found, please launch this feature again from the workday screen."
      redirect_to root_path
    elsif !session[:self_tracking_expires_at].present?
      flash[:danger] = "Session expiration missing, please launch this feature again."
      redirect_to root_path
    elsif session[:self_tracking_expires_at] < DateTime.now
      flash[:danger] = "Session expired, please launch this feature again."
      redirect_to root_path
    end
  end


  def launch
    @workday = Workday.find(params[:id])
    user_id = session[:user_id]
    log_out

    # Save the workday in the session
    session[:self_tracking_workday_id] = @workday.id
    session[:self_tracking_expires_at] = DateTime.now + 1   # Expire after 1 day
    session[:self_tracking_launching_user_id] = user_id

    if params[:check_out_all] == "true"
      redirect_back_or self_tracking_check_out_all_path
    else
      redirect_to action: "index"
    end
  end


  def index
    @workday = Workday.find(session[:self_tracking_workday_id])
    @project = Project.find(@workday.project_id)
  end


  def volunteer_search
    # If we are doing a guardian search, need to pass through original volunteer
    if params[:guardian_search]
      @volunteer = Volunteer.including_pending.find(params[:volunteer_id])
    else
      session.delete(:check_in_volunteer)
    end

    if params[:search_form].present?
      @search_form = SearchForm.new(params.require(:search_form).permit(:name, :phone, :email))
      if @search_form.valid?
        last_name, first_name = @search_form.name.split(",")

        last_name.strip!

        # if record(s) match fuzzy name, phone, OR email, count that as a match and present them to select from.
        where_clause = Volunteer.get_fuzzymatch_where_clause("last_name", last_name) if last_name.present?
        if first_name.present?
          first_name.strip!
          where_clause += " AND " if where_clause.present?
          where_clause += Volunteer.get_fuzzymatch_where_clause("first_name", first_name)
        end

        if @search_form.phone.present?
          where_clause += " AND (mobile_phone = %{phone} OR work_phone = %{phone} OR home_phone = %{phone})" % {
              :phone => Volunteer.sanitize(@search_form.phone)}
        end


        where_clause = "(#{where_clause})"
        where_clause += " OR (email = #{Volunteer.sanitize(@search_form.email)})" if @search_form.email.present?

        @results = Volunteer.including_pending.where(where_clause).order(:last_name, :first_name)

        if params[:guardian_search]
          @results = @results.select { |g| g.adult == true || (g.birthdate && (age(g.birthdate) >= Utilities::Utilities.system_setting(:adult_age)))}
          render partial: "guardian_search_results"
        else
          render partial: "search_results"
        end
      else
        if params[:guardian_search]
          render partial: "guardian_search"
        else
          render partial: "volunteer_search"
        end
      end
    else
      @search_form = SearchForm.new()
      if params[:guardian_search]
        render partial: "guardian_search"
      else
        render partial: "volunteer_search"
      end
    end
  end


  def check_in
    if !session[:check_in_volunteer].nil?
      @volunteer = Volunteer.including_pending.find(session[:check_in_volunteer])
      @guardian = Volunteer.including_pending.find(params[:id])
      session.delete :check_in_volunteer
    else
      @volunteer = Volunteer.including_pending.find(params[:id])
    end
    if !params[:guardian_id].blank?
      @guardian = Volunteer.including_pending.find(params[:guardian_id])
    end
    @workday = Workday.find(session[:self_tracking_workday_id])

    # Handle forms
    # Handle check-in time form
    if params[:check_in_form].present?
      @check_in_form = CheckInForm.new(params.require(:check_in_form).permit(:check_in_time).merge(volunteer: @volunteer, workday: @workday))
      if @check_in_form.valid?
        start_time = Time.strptime(@check_in_form.check_in_time, "%I:%M %P")
        start_time_formatted = start_time.strftime("%H:%M:%S")

        # If there is an existing later shift on the same day then automatically check-out the new
        # check-in a certain time before the future shift.
        end_time = nil
        future_shifts = @workday.workday_volunteers.where(
            "volunteer_id = ? AND start_time >= ?", @volunteer.id, start_time_formatted
        )
        if future_shifts.count > 0
          start_time = future_shifts.first.start_time.strftime("%-I:%M %P")
          flash[:warning] = "Another shift starts at #{start_time}, please remember to check out this shift before #{start_time}."
        else
          flash[:success] = "#{@volunteer.name} successfully checked in."
        end

        @workday.workday_volunteers.create(:volunteer => @volunteer, :start_time => start_time_formatted, :end_time => end_time)
        render plain: "success"
        return
      else
        render partial: "check_in"
        return
      end
    end
    # Handle waiver signing form
    if params[:need_waiver_form].present? && !params[:skip_waiver]
      @need_waiver_form = NeedWaiverForm.new(params[:need_waiver_form].permit(:waiver_type).merge(volunteer: @volunteer, guardian: @guardian))
      if @need_waiver_form.valid?
        if (@need_waiver_form.waiver_type.to_i == WaiverText.waiver_types[:adult].to_i)
          Waiver.create(volunteer_id: @volunteer.id, e_sign: true, adult: true, date_signed: Time.zone.now.to_date)
        else
          Waiver.create(volunteer_id: @volunteer.id, guardian_id: @guardian.id, e_sign: true, adult: false, date_signed: Time.zone.now.to_date)
        end
      else
        render partial: "need_waiver"
        return
      end
    end
    # Handle Birthdate/Adult form
    if params[:need_age_form].present?
      @need_age_form = NeedAgeForm.new(params[:need_age_form].permit(:birthdate, :adult))
      if @need_age_form.valid?
        @volunteer.update_attributes(params.require(:need_age_form).permit(:birthdate, :adult))
      else
        render partial: "need_age"
        return
      end
    end

    # Check that we have the necessary info for check-in, otherwise put up forms
    # Do we need to determine age?
    if @volunteer.birthdate.blank? && (@volunteer.adult != true)
      @need_age_form = NeedAgeForm.new()
      render partial: "need_age"
      return
    end
    # Do we need a waiver?
    if Utilities::Utilities.system_setting(:waivers_at_checkin)
      @waiver_type = need_waiver_type(@volunteer)
      if @waiver_type && !params[:skip_waiver]
        last_waiver = last_waiver(@volunteer.id)
        # If a minor and we don't have a guardian yet, get one
        if @waiver_type == WaiverText.waiver_types[:minor] && !@guardian
          guardian_id = last_waiver ? last_waiver.guardian_id : nil
          @guardian = guardian_id ? Volunteer.including_pending.find(guardian_id) : nil
          @search_form = SearchForm.new()
          session[:check_in_volunteer] = @volunteer.id  # Save since we are now going to look for a guardian
          render partial: "guardian_search"
          return
        else
          # We have what we need, get waiver signed
          @need_waiver_form = NeedWaiverForm.new()
          render partial: "need_waiver"
          return
        end
      end
    end

    # All good, ready to check-in

    @check_in_form = CheckInForm.new(check_in_time:  nil, volunteer: @volunteer, workday: @workday)
    render partial: "check_in"

  end


  def check_out
    # Only look for the record within the current workday.
    @workday = Workday.find(session[:self_tracking_workday_id])
    @workday_volunteer = @workday.workday_volunteers.find(params[:workday_volunteer_id])

    if params[:check_out_form].present?
      @check_out_form = CheckOutForm.new(params.require(:check_out_form).permit(:check_out_time).merge(workday_volunteer: @workday_volunteer))
      if @check_out_form.valid?
        @workday_volunteer.end_time = Time.strptime(@check_out_form.check_out_time, "%I:%M %P").strftime("%H:%M:%S")
        if @workday_volunteer.valid?
          @workday_volunteer.save
          flash[:success] = "#{@workday_volunteer.volunteer.name} successfully checked out."
          render plain: "success"
        else
          render partial: "check_out"
        end
      else
        render partial: "check_out"
      end
    else
      @check_out_form = CheckOutForm.new(
          workday_volunteer: @workday_volunteer, check_out_time:  nil)
      render partial: "check_out"
    end
  end

  def check_out_all
    @workday = Workday.find(session[:self_tracking_workday_id])
    if params[:check_out_all_form].present?
      @check_out_all_form = Check_out_all_form.new(params.require(:check_out_all_form).merge(workday: @workday))
      if @check_out_all_form.valid?

        unupdated_volunteers = Hash.new(0)

        @workday.workday_volunteers.each do |workday_volunteer|
          if workday_volunteer.end_time.nil?
            workday_volunteer.end_time = Time.strptime(@check_out_all_form.check_out_time, "%I:%M %P").strftime("%H:%M:%S")
            if workday_volunteer.start_time.nil?
              workday_volunteer.start_time = workday_volunteer.end_time - 4.hours # Assume 4 hours if ambiguous
            end
            if !workday_volunteer.is_end_time_valid
              unupdated_volunteers[workday_volunteer.volunteer_id.to_s] = 'End time is before start time.'
            elsif @workday.is_overlapping_volunteer(workday_volunteer)
              unupdated_volunteers[workday_volunteer.volunteer_id.to_s] = 'End time overlaps another workday entry for this volunteer'
            else
              workday_volunteer.save
            end
          end
        end

        if unupdated_volunteers.length == 0
          redirect_to self_tracking_index_path
        else
          session[:unupdated_date] = Time.parse(@check_out_all_form.check_out_time).strftime("%l:%M %p")
          session[:unupdated_message] = unupdated_volunteers
          redirect_to self_tracking_index_path
        end
      end

    elsif params[:login].present?
      redirect_to login_path(:target_url => self_tracking_launch_url(:id=> session[:self_tracking_workday_id], :check_out_all => true))
    else
      @check_out_all_form = Check_out_all_form.new(workday: @workday, check_out_time: nil)
    end
  end
end

class Check_out_all_form
  include ActiveModel::Model
  attr_accessor :check_out_time, :workday, :allSuccess
  validates_presence_of :check_out_time
end

# Class for simple validation of the search form
class SearchForm
  include ActiveModel::Model
  attr_accessor :name, :phone, :email
  validates_presence_of :name
end

# Class for simple validation of the check-in form. I intentionally didn't validate
# the time field because the regular Workday/Volunteer flow wasn't validating it
# either.  Maybe this should be added at some point.  strftime in the controller
# will cause an error if the time is invalid.
class CheckInForm
  include ActiveModel::Model
  attr_accessor :check_in_time, :volunteer, :workday
  validates_presence_of :check_in_time
  validate :overlapping_check_in, :if => lambda { @check_in_time.present? }

  def overlapping_check_in
    check_in_time = Time.strptime(@check_in_time, "%I:%M %P").strftime("%H:%M:%S")

    # Don't allow overlapping check-ins.
    if @workday.workday_volunteers.where(
        "(volunteer_id = :volunteer_id) AND (start_time <= :time) AND ((end_time IS NULL) OR (end_time >= :time))",
        {volunteer_id: @volunteer.id, time: check_in_time}
    ).count > 0
      errors.add(:base, "You are already checked in at this time.")
    end
  end
end

class NeedWaiverForm
  include ActiveModel::Model
  attr_accessor :volunteer, :guardian, :waiver_type
end

class NeedGuardianForm
  include ActiveModel::Model
  attr_accessor :volunteer, :guardian
  validates_presence_of :guardian
  validate :guardian_not_self

  def guardian_not_self
    if @guardian.id == @volunteer.id
      errors.add(:base, "You can't be the guardian")
    end
  end
end

class NeedAgeForm
  include ActiveModel::Model
  attr_accessor :birthdate, :adult
  validate :birthdate_or_adult

  def birthdate_or_adult
    if @birthdate.blank? && (@adult != "1")
      # puts "adding error"
      errors.add(:need_age, "Enter your birthdate or declare that you are #{Utilities::Utilities.system_setting(:adult_age)} or older.")
    else
      # puts "No errors"
    end
  end
end


class CheckOutForm
  include ActiveModel::Model
  attr_accessor :check_out_time, :workday_volunteer
  validates_presence_of :check_out_time
  validate :overlapping_check_out, :if => lambda { @check_out_time.present? }

  def overlapping_check_out
    end_time = Time.strptime(@check_out_time, "%I:%M %P")
    workday = @workday_volunteer.workday
    volunteer = @workday_volunteer.volunteer

    # Confirm that check out time is after the check in time.
    if end_time.strftime("%H%M%S").to_i <= @workday_volunteer.start_time.strftime("%H%M%S").to_i
      errors.add(:check_out_time, "must be after the check-in time.")
    else
      # Don't allow overlapping check outs.
      overlapping_shifts = workday.workday_volunteers.where(
          "(volunteer_id = :volunteer_id) AND (id != :this_workday_volunteer_id) AND
		(start_time > :this_start_time) AND (:this_end_time >= start_time)",
          {
              volunteer_id: volunteer.id, this_workday_volunteer_id: @workday_volunteer.id,
              this_start_time: @workday_volunteer.start_time.strftime("%H:%M:%S"),
              this_end_time: end_time.strftime("%H:%M:%S")
          })
      if overlapping_shifts.count > 0
        errors.add(
            :base,
            "You have another shift starting at %{next_shift}, you must check out before its start." % {
                next_shift: overlapping_shifts.first.start_time.strftime("%l:%M %P")
            }
        )
      end
    end
  end
end
