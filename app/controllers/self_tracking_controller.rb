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

    redirect_to action: "index"
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

        where_clause = []
        where_clause.push(Volunteer.get_fuzzymatch_where_clause("last_name", last_name)) if last_name.present?
        where_clause.push(Volunteer.get_fuzzymatch_where_clause("first_name", first_name)) if first_name.present?
        where_clause.push("email = #{Volunteer.sanitize(@search_form.email)}") if @search_form.email.present?
        where_clause.push("(mobile_phone LIKE %{phone} OR work_phone LIKE %{phone} OR home_phone LIKE %{phone})" % {
          :phone => "#{Volunteer.sanitize(@search_form.phone)}"}) if @search_form.phone.present?

        @results = Volunteer.including_pending.where(where_clause.join(" OR ")).order(:last_name, :first_name)

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
    @newly_signed_up = params[:newly_signed_up]

    if params[:check_in_form].present?
      @check_in_form = CheckInForm.new(params[:check_in_form])
      if @check_in_form.valid?
        @workday = Workday.find(session[:self_tracking_workday_id])
        start_time = Time.strptime(@check_in_form.check_in_time, "%I:%M %P").strftime("%H:%M:%S")

        # TODO
        # Check that this isn't an overlapping check_in
        # Check that this isn't a duplicate check_in
        @workday.workday_volunteers.create(:volunteer => @volunteer, :start_time => start_time)

        flash[:success] = "Successfully checked in #{@volunteer.name}."

        render :text => "success"
      else
        render partial: "check_in"
      end
    else
      @check_in_form = CheckInForm.new()
      render partial: "check_in"
    end
  end


  def checkout
    # Only look for the record within the current workday.
    @workday = Workday.find(session[:self_tracking_workday_id])
    workday_volunteer = @workday.workday_volunteers.find(params[:workday_volunteer_id])
    workday_volunteer.end_time = DateTime.now.strftime("%H:%M:%S")
    if workday_volunteer.valid?
      workday_volunteer.save
      flash[:success] = "#{workday_volunteer.volunteer.name} successfully checked out."
    else
      flash[:danger] = workday_volunteer.errors.full_messages
    end
    redirect_to self_tracking_index_path
  end


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
  attr_accessor :check_in_time
  validates_presence_of :check_in_time
end
