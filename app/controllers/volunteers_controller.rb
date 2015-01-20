class VolunteersController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy]
  before_action :admin_user,     only: :destroy


  # GET /users
  # GET /users.json
  def index
    @volunteers = Volunteer.paginate(page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @volunteer = Volunteer.find(params[:id])
  end

  # GET /users/new
  def new
    @volunteer = Volunteer.new
  end

  # GET /users/1/edit
  def edit
    @volunteer = Volunteer.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save
      redirect_to volunteers_path, notice: 'Volunteer was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.update_attributes(volunteer_params)
      flash[:success] = "Volunteer updated"
      redirect_to root_url
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
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


end
