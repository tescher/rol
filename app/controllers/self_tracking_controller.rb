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
    @newly_signed_up = params[:newly_signed_up]

    if params[:check_in_form].present?
	  @workday = Workday.find(session[:self_tracking_workday_id])
	  @check_in_form = CheckInForm.new(params[:check_in_form].merge(volunteer: @volunteer, workday: @workday))
      if @check_in_form.valid?
        start_time = Time.strptime(@check_in_form.check_in_time, "%I:%M %P")
        start_time_formatted = start_time.strftime("%H:%M:%S")

		# If there is an existing later shift on the same day then automatically check-out the new
		# check-in a certain time before the future shift.
		end_time = nil
		if @workday.workday_volunteers.where("volunteer_id = ? AND start_time >= ?", @volunteer.id, start_time_formatted).count > 0
		  future_shift = @workday.workday_volunteers.where(
			"volunteer_id = ? AND start_time >= ?", @volunteer.id, start_time_formatted).order(:start_time).first
		  end_time = (future_shift.start_time - 30.minutes)
		  if end_time.strftime("%H%M%S").to_i <= start_time.strftime("%H%M%S").to_i
			end_time = future_shift.start_time - 1.minute
		  end
		  flash[:warning] = "A future shift started at #{future_shift.start_time.strftime("%-I:%M %P")} so the new check-in was automatically checked-out before the start of this shift (#{end_time.strftime("%-I:%M %P")})."
		  end_time = end_time.strftime("%H:%M:%S")
		else
		  flash[:success] = "Successfully checked in #{@volunteer.name}."
		end
	
		@workday.workday_volunteers.create(:volunteer => @volunteer, :start_time => start_time_formatted, :end_time => end_time)
        render :text => "success"
      else
        render partial: "check_in"
      end
    else
      @check_in_form = CheckInForm.new(volunteer: @volunteer, workday: @workday)
      render partial: "check_in"
    end
  end


  def checkout
    # Only look for the record within the current workday.
    @workday = Workday.find(session[:self_tracking_workday_id])
    workday_volunteer = @workday.workday_volunteers.find(params[:workday_volunteer_id])
    workday_volunteer.end_time = Time.now.strftime("%H:%M:%S")
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
  attr_accessor :check_in_time, :volunteer, :workday
  validates_presence_of :check_in_time
  validate :overlapping_check_in, :if => lambda {|attr| attr.present?}

  def overlapping_check_in
	return if @check_in_time.empty?
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
