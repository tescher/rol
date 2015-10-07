class DonationTypesController < ApplicationController
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /donation_types/1
  # GET /donation_types/1.json
  def show
    @donation_type = DonationType.find(params[:id])
  end

  # GET /donation_types/new
  def new
    @donation_type = DonationType.new
  end

  # GET /donation_types/1/edit
  def edit
    @donation_type = DonationType.find(params[:id])
  end

  def index
    @donation_types = DonationType.paginate(page: params[:page])
  end

  # POST /donation_types
  # POST /donation_types.json
  def create
    @donation_type = DonationType.new(donation_type_params)
    if @donation_type.save
      redirect_to donation_types_path, notice: 'donation type was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /donation_types/1
  # PATCH/PUT /donation_types/1.json
  def update
    @donation_type = DonationType.find(params[:id])
    if @donation_type.update_attributes(donation_type_params)
      flash[:success] = "donation type updated"
      redirect_to donation_types_path
    else
      render :edit
    end
  end


  # DELETE /donation_types/1
  # DELETE /donation_types/1.json
  def destroy
    @donation_type = DonationType.find(params[:id])
    @donations = Donation.where(donation_type_id: @donation_type.id)
    if @donations.count > 0
      flash.now[:danger] = "Cannot delete donation type, it is attached to an donation"
      render :edit
    else
      @donation_type.destroy
      flash[:success] = "donation type deleted"
      redirect_to donation_types_path
    end
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
  def donation_type_params
    params.require(:donation_type).permit(:name, :non_monetary, :inactive)
  end
end
