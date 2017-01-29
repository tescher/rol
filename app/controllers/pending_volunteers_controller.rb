require 'digest'
include ApplicationHelper
include VolunteersHelper

class PendingVolunteersController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_user, only: [:index, :update, :match, :edit, :destroy]

  def new
    @object = Volunteer.pending.new()
    @launched_from_self_tracking = params[:launched_from_self_tracking]
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

      params[:pv_use_fields].each do |findex|
        item = Volunteer.pending_volunteer_merge_fields_table.key(findex.to_i)
        volunteer_params[item] = pending_volunteer_params[item]
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

      interests = []
      if (pending_volunteer_params[:interest_ids].length > 0) && (params[:use_interests].downcase != "ignore")
        if (params[:use_interests].downcase == "add") && (!params[:volunteer_interest_ids].nil?)
          volunteer_params[:interest_ids] = (pending_volunteer_params[:interest_ids] + params[:volunteer_interest_ids]).uniq
        else
          volunteer_params[:interest_ids] = pending_volunteer_params[:interest_ids].dup
        end
      end

      if @volunteer.update_attributes(volunteer_params)
        flash[:success] = "Volunteer updated"
        @object.deleted_reason = "Merged pending volunteer into #{@volunteer.id}"
        @object.save
        @object.destroy
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
    @launched_from_self_tracking = params[:launched_from_self_tracking]
    @object.work_phone = @object.mobile_phone = @object.home_phone
    status = verify_google_recptcha(GOOGLE_SECRET_KEY,params["g-recaptcha-response"])
    if status && @object.save  # Order is important here!
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
      :mobile_phone, :email, :notes, int_ids: [], interest_ids: []
    )
    if (!modified_params[:int_ids].nil?)
      modified_params[:interest_ids] = modified_params[:int_ids].dup
      modified_params.delete(:int_ids)
    end
    # puts modified_params
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
