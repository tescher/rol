require 'digest'
include ApplicationHelper
include VolunteersHelper

class PendingVolunteersController < ApplicationController
  before_action { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_user, only: [:index, :update, :match, :edit, :destroy]

  def new
    @object = Volunteer.pending.new()
    @launched_from_self_tracking = params[:launched_from_self_tracking]
    @self_tracking_enabled = session[:self_tracking_workday_id].present? && Workday.exists?(session[:self_tracking_workday_id])
    session[:referer] = request.referer
    @submit_name = "Submit"
    render 'new'
  end

  def edit
    @object = Volunteer.pending.find(params[:id])
    if params[:matching_id].blank?
      redirect_to root_path
    else
      @volunteer = Volunteer.find(params[:matching_id])
    end
  end

  def update
    @object = Volunteer.pending.find(params[:id])
    if params[:matching_id].blank?
      redirect_to root_path
    else
      # Lookup the actual matching volunteer
      @volunteer = Volunteer.find(params[:matching_id])
      volunteer_params = {}

      if params[:pv_use_fields]
        params[:pv_use_fields].each do |findex|
          item = Volunteer.pending_volunteer_merge_fields_table.key(findex.to_i)
          volunteer_params[item] = pending_volunteer_params[item]
        end
      end

      if (params[:use_notes].downcase != "ignore")
        if @volunteer.notes.blank? || (params[:use_notes].downcase == "replace")
          volunteer_params[:notes] = pending_volunteer_params[:notes]
        else
          if (!pending_volunteer_params[:notes].blank?)
            if (params[:use_notes].downcase == "append")
              volunteer_params[:notes] = @volunteer.notes + "\n " + pending_volunteer_params[:notes]
            else
              if (params[:use_notes].downcase == "prepend")
                volunteer_params[:notes] =  pending_volunteer_params[:notes] + "\n " + @volunteer.notes
              end
            end
          end
        end
      end
      if (params[:use_limitations].downcase != "ignore")
        if @volunteer.limitations.blank? || (params[:use_limitations].downcase == "replace")
          volunteer_params[:limitations] = pending_volunteer_params[:limitations]
        else
          if (!pending_volunteer_params[:limitations].blank?)
            if (params[:use_limitations].downcase == "append")
              volunteer_params[:limitations] = @volunteer.limitations + "\n " + pending_volunteer_params[:limitations]
            else
              if (params[:use_limitations].downcase == "prepend")
                volunteer_params[:limitations] =  pending_volunteer_params[:limitations] + "\n " + @volunteer.limitations
              end
            end
          end
        end
      end
      if (params[:use_medical_conditions].downcase != "ignore")
        if @volunteer.medical_conditions.blank? || (params[:use_medical_conditions].downcase == "replace")
          volunteer_params[:medical_conditions] = pending_volunteer_params[:medical_conditions]
        else
          if (!pending_volunteer_params[:medical_conditions].blank?)
            if (params[:use_medical_conditions].downcase == "append")
              volunteer_params[:medical_conditions] = @volunteer.medical_conditions + "\n " + pending_volunteer_params[:medical_conditions]
            else
              if (params[:use_medical_conditions].downcase == "prepend")
                volunteer_params[:medical_conditions] =  pending_volunteer_params[:medical_conditions] + "\n " + @volunteer.medical_conditions
              end
            end
          end
        end
      end

      interests = []
      if (pending_volunteer_params[:interest_ids].length > 0) && (params[:use_interests].downcase != "ignore")
        if (params[:use_interests].downcase == "add") && (!params[:volunteer_interest_ids].nil?)
          volunteer_params[:interest_ids] = (pending_volunteer_params[:interest_ids] + params[:volunteer_interest_ids]).uniq
        else
          volunteer_params[:interest_ids] = pending_volunteer_params[:interest_ids].dup
        end
      end

      if @volunteer.update_attributes(volunteer_params)
        # Move workdays and waivers
        WorkdayVolunteer.where("volunteer_id = #{@object.id}").each do |sw|
          workday = sw.dup
          workday.volunteer_id = @volunteer.id
          workday.save!
          sw.destroy!
        end
        deletable_waivers = []
        Waiver.where("volunteer_id = #{@object.id}").each do |swv|
          waiver = swv.dup
          waiver.volunteer_id = @volunteer.id
          waiver.save!
          deletable_waivers.push swv
            # swv.really_destroy!
        end
        Waiver.where("guardian_id = #{@object.id}").each do |swv|
          waiver = swv.dup
          waiver.guardian_id = @volunteer.id
          waiver.save!
          unless deletable_waivers.include?(swv)
            deletable_waivers.push swv
          end
            # swv.really_destroy!
        end

        # Need to do it this way because a person can be a volunteer and guardian on the same waiver
        deletable_waivers.each do |wv|
          wv.really_destroy!
        end

        flash[:success] = "Volunteer updated."
        @object.deleted_reason = "Merged pending volunteer into #{@volunteer.id}"
        @object.save!
        @object.destroy!
        redirect_to pending_volunteers_path
      else
        @volunteer.errors.each {|attr, error| @object.errors.add(attr, error)}
        @volunteer.reload
        render :edit
      end

    end
  end


  def index
    standard_index(Volunteer.pending.all, params[:page], false, "", nil, true)
  end

  def match
    @pending_volunteer = Volunteer.pending.find(params[:id])
    @matched_volunteers = find_matching_volunteers(@pending_volunteer)
  end

  def destroy
    Volunteer.pending.find(params[:id]).really_destroy!
    flash[:success] = "Pending Volunteer discarded"
    redirect_to pending_volunteers_path
  end

  def create
    @object = Volunteer.pending.new(pending_volunteer_params)
    @object.work_phone = @object.mobile_phone = @object.home_phone
    if !@object.notes.blank?
      @object.notes = "Reason for volunteering: ""#{@object.notes}"""
    end

    @launched_from_self_tracking = params[:launched_from_self_tracking]
    @self_tracking_enabled = session[:self_tracking_workday_id].present? && Workday.exists?(session[:self_tracking_workday_id])
    # Don't check recaptcha is self tracking is enabled.
    status = @self_tracking_enabled ? true : verify_google_recptcha(GOOGLE_SECRET_KEY,params["g-recaptcha-response"])

    if status && @object.save  # Order is important here!
      PendingVolunteerMailer.notification_email(@object).deliver_now
      render 'success'
    else
      if !status
        @object.errors.add(:captcha, " - Be sure to click the No Robots box")
      end
      @submit_name = "Submit"
      render 'new'
    end
  end

  def show

  end

  private

  def pending_volunteer_params
    modified_params = params.require(:volunteer).permit(
        :first_name, :last_name, :address, :city, :state, :zip, :home_phone, :work_phone,
        :mobile_phone, :email, :notes, :occupation, :emerg_contact_name, :emerg_contact_phone, :limitations, :medical_conditions, :agree_to_background_check, :birthdate, :adult, interest_ids: []
    )
    modified_params
  end

  def verify_google_recptcha(secret_key,response)
    status = `curl "https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{response}"`
    logger.info "---------------status ==> #{status}"
    hash = JSON.parse(status)
    error_codes = hash["error-codes"]
    (hash["success"] == true || error_codes.include?("invalid-input-secret")) ? true : false
  end

end
