include ApplicationHelper

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
    if params[:search_form].present?
      @search_form = SearchForm.new(params[:search_form])
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

        render partial: "search_results"
      else
        render partial: "volunteer_search"
      end
    else
      @search_form = SearchForm.new()
      render partial: "volunteer_search"
    end
  end


  def check_in
    @volunteer = Volunteer.including_pending.find(params[:id])
	  @workday = Workday.find(session[:self_tracking_workday_id])
    @newly_signed_up = params[:newly_signed_up]

    if params[:check_in_form].present?
	  @check_in_form = CheckInForm.new(params[:check_in_form].merge(volunteer: @volunteer, workday: @workday))
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
        render :text => "success"
      else
        render partial: "check_in"
      end
    else
      @check_in_form = CheckInForm.new(check_in_time:  Time.now.strftime("%l:%M %p"), volunteer: @volunteer, workday: @workday)
      render partial: "check_in"
    end
  end


  def check_out
    # Only look for the record within the current workday.
    @workday = Workday.find(session[:self_tracking_workday_id])
    @workday_volunteer = @workday.workday_volunteers.find(params[:workday_volunteer_id])

    if params[:check_out_form].present?
	    @check_out_form = CheckOutForm.new(params[:check_out_form].merge(workday_volunteer: @workday_volunteer))
    if @check_out_form.valid?
		  @workday_volunteer.end_time = Time.strptime(@check_out_form.check_out_time, "%I:%M %P").strftime("%H:%M:%S")
		if @workday_volunteer.valid?
		  @workday_volunteer.save
		  flash[:success] = "#{@workday_volunteer.volunteer.name} successfully checked out."
		  render :text => "success"
		else
		  render partial: "check_out"
		end
      else
		render partial: "check_out"
      end
    else
      @check_out_form = CheckOutForm.new(
		      workday_volunteer: @workday_volunteer, check_out_time:  Time.now.strftime("%l:%M %p"))
      render partial: "check_out"
    end
  end

  def check_out_all
    @workday = Workday.find(session[:self_tracking_workday_id])
    if params[:check_out_all_form].present?
      @check_out_all_form = Check_out_all_form.new(params[:check_out_all_form].merge(workday: @workday))
      if @check_out_all_form.valid?
        is_all_updated = true
        @workday.workday_volunteers.each do |workday_volunteer|
          if workday_volunteer.end_time.nil?
            workday_volunteer.end_time = Time.parse(@check_out_all_form.check_out_time)
            if workday_volunteer.is_end_time_valid && !@workday.is_overlapping_volunteer(workday_volunteer)
              workday_volunteer.save
            else
              is_all_updated = false
            end
          end
        end

        if is_all_updated
          redirect_to self_tracking_index_path
        else
          flash[:danger] = "Attention! Not all volunteers were checked out"
          redirect_to self_tracking_index_path
        end
      end

    elsif params[:login].present?
      redirect_to login_path(:target_url => self_tracking_launch_url(:id=> session[:self_tracking_workday_id], :check_out_all => true))
    else
      @check_out_all_form = Check_out_all_form.new(workday: @workday, check_out_time: Time.now.strftime("%l:%M %p"))
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
