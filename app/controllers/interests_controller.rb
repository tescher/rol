class InterestsController < ApplicationController
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /interests/1
  # GET /interests/1.json
  def show
    @interest = Interest.find(params[:id])
  end

  # GET /interests/new
  def new
    @interest = Interest.new
  end

  # GET /interests/1/edit
  def edit
    @interest = Interest.find(params[:id])
  end

  def index
    @interests = Interest.paginate(page: params[:page])
  end

  # POST /interests
  # POST /interests.json
  def create
    @interest = Interest.new(interest_params)
    if @interest.save
      redirect_to interests_path, notice: 'interest was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /interests/1
  # PATCH/PUT /interests/1.json
  def update
    @interest = Interest.find(params[:id])
    if @interest.update_attributes(interest_params)
      flash[:success] = "interest updated"
      redirect_to interests_path
    else
      render :edit
    end
  end

  # DELETE /interests/1
  # DELETE /interests/1.json
  def destroy
    Interest.find(params[:id]).destroy
    flash[:success] = "interest deleted"
    redirect_to interests_path
  end
  
  private
  
  # Confirms an admin user.
  def logged_in_admin_user
    if logged_in?
      redirect_to(root_url) unless current_user.admin?
    else
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def interest_params
    params.require(:interest).permit(:name, :category, :highlight)
  end



end
