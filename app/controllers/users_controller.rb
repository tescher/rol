include ApplicationHelper

class UsersController < ApplicationController
  before_action :logged_in_user, only: [:new, :index, :edit, :show, :update, :destroy]
  before_action :correct_or_admin_user, only: [:edit, :update, :destroy]
  before_action :admin_user,     only: [:index, :new ]


  # GET /users
  # GET /users.json
  def index
    @users = User.paginate(page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
     if @user.save
         flash[:success] = 'User was successfully created.'
         redirect_to users_url
     else
         render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to users_url
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
      flash[:danger] = "Cannot delete yourself"
    else
      @user.destroy
      flash[:success] = "User deleted"
    end
    redirect_to users_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if current_user.admin?
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin, :all_donations, :non_monetary_donations, :can_edit_unowned_contacts, :notify_if_pending)
      else
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end

    # Before filters

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Correct user or admin
    def correct_or_admin_user
      redirect_to(root_url) unless current_user?(User.find(params[:id])) || current_user.admin?
    end


end
