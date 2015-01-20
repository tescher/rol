class VolunteersController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search]
  before_action :admin_user,     only: :destroy


  def search

  end

  # GET /volunteers
  def index
    where_clause = ""
    volunteer_search_params.each do |index|
      pp index
      pp index[0]
      pp index[1]
      if ["last_name", "city"].include?(index[0])
        if index[1].strip.length > 0
          where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
          where_clause += "(soundex(#{index[0]}) = soundex('#{index[1]}') OR (LOWER(#{index[0]}) LIKE '#{index[1].downcase}%'))"
        end
      end
    end
    @volunteers = where_clause.length > 0 ? Volunteer.where(where_clause).paginate(page: params[:page]) : Volunteer.paginate(page: params[:page])
  end

  # GET /volunteers/1
  # GET /volunteers/1.json
  def show
    @volunteer = Volunteer.find(params[:id])
  end

  # GET /volunteers/new
  def new
    @volunteer = Volunteer.new
  end

  # GET /volunteers/1/edit
  def edit
    @volunteer = Volunteer.find(params[:id])
  end

  # POST /volunteers
  # POST /volunteers.json
  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save
      redirect_to volunteers_path, notice: 'Volunteer was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /volunteers/1
  # PATCH/PUT /volunteers/1.json
  def update
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.update_attributes(volunteer_params)
      flash[:success] = "Volunteer updated"
      redirect_to root_url
    else
      render :edit
    end
  end

  # DELETE /volunteers/1
  # DELETE /volunteers/1.json
  def destroy
    Volunteer.find(params[:id]).destroy
    flash[:success] = "Volunteer deleted"
    redirect_to users_url
  end

  private

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :middle_name, :email, :occupation,
                                      :address, :city, :state, :zip, :home_phone, :work_phone, :mobile_phone,
                                      :notes)
  end
  def volunteer_search_params
    params.permit(:last_name, :city)
  end


end
