require 'digest'
include ApplicationHelper

class PendingVolunteersController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_user, only: [:index, :update, :match]

  def new
    @object = PendingVolunteer.new
    session[:referer] = request.referer
    @submit_name = "Submit"
    render 'new'
  end

  def update

  end

  def index
    standard_index(PendingVolunteer.where(resolved: false), params[:page], false, "", nil, true)
  end

  def match
    @pending_volunteer = PendingVolunteer.find(params[:id])
    @matched_volunteers = Hash.new
    volunteer_ids = []
    @volunteers = Volunteer.where("last_name ILIKE ?",@pending_volunteer.last_name)
    @volunteers.each do |v|
      volunteer_ids.push(v.id)
      matched_volunteer = {volunteer: v, points: 10}
      @matched_volunteers[v.id] = matched_volunteer
    end
    @volunteers = Volunteer.where(id: volunteer_ids).where("soundex(last_name) = soundex(#{Volunteer.sanitize(@pending_volunteer.last_name)})")
    @volunteers.each do |v|
      @matched_volunteers[v.id][:points] += 5
    end
    if (!@pending_volunteer.first_name.blank?)
      @volunteers = Volunteer.where(id: volunteer_ids).where("first_name ILIKE ?",@pending_volunteer.first_name)
      @volunteers.each do |v|
        @matched_volunteers[v.id][:points] += 5
      end
      @volunteers = Volunteer.where(id: volunteer_ids).where("first_name ILIKE ?",@pending_volunteer.first_name + "%")
      @volunteers.each do |v|
        @matched_volunteers[v.id][:points] += 3
      end
      @volunteers = Volunteer.where(id: volunteer_ids).where("soundex(last_name) = soundex(#{Volunteer.sanitize(@pending_volunteer.first_name)})")
      @volunteers.each do |v|
        @matched_volunteers[v.id][:points] += 2
      end
    end
    if (!@pending_volunteer.email.blank?)
      @volunteers = Volunteer.where(id: volunteer_ids).where("email ILIKE ?",@pending_volunteer.email)
      @volunteers.each do |v|
        @matched_volunteers[v.id][:points] += 10
      end
    end
    if (!@pending_volunteer.city.blank?)
      @volunteers = Volunteer.where(id: volunteer_ids).where("city ILIKE ?",@pending_volunteer.city)
      @volunteers.each do |v|
        @matched_volunteers[v.id][:points] += 2
      end
    end
    @matched_volunteers = Hash[@matched_volunteers.sort_by { |id, mv| -mv[:points]}[0..4]]
  end

  def destroy

  end

  def create
    @object = PendingVolunteer.new(pending_volunteer_params)
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
    modified_params = params.require(:pending_volunteer).permit(:first_name, :last_name, :address, :city, :state, :zip, :phone, :email, :notes, pv_int_ids: [] )
    if (!modified_params[:pv_int_ids].nil?)
      modified_params[:interest_ids] = modified_params[:pv_int_ids].dup
    end
    modified_params.delete(:pv_int_ids)
    puts modified_params
    modified_params
  end

  def verify_google_recptcha(secret_key,response)
    status = `curl "https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{response}"`
    logger.info "---------------status ==> #{status}"
    hash = JSON.parse(status)
    hash["success"] == true ? true : false
  end

end
