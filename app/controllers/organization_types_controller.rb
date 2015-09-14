class OrganizationTypesController < ApplicationController
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /organization_types/1
  # GET /organization_types/1.json
  def show
    @organization_type = OrganizationType.find(params[:id])
  end

  # GET /organization_types/new
  def new
    @organization_type = OrganizationType.new
  end

  # GET /organization_types/1/edit
  def edit
    @organization_type = OrganizationType.find(params[:id])
  end

  def index
    @organization_types = OrganizationType.paginate(page: params[:page])
  end

  # POST /organization_types
  # POST /organization_types.json
  def create
    @organization_type = OrganizationType.new(organization_type_params)
    if @organization_type.save
      redirect_to organization_types_path, notice: 'organization type was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /organization_types/1
  # PATCH/PUT /organization_types/1.json
  def update
    @organization_type = OrganizationType.find(params[:id])
    if @organization_type.update_attributes(organization_type_params)
      flash[:success] = "organization type updated"
      redirect_to organization_types_path
    else
      render :edit
    end
  end


  # DELETE /organization_types/1
  # DELETE /organization_types/1.json
  def destroy
    @organization_type = OrganizationType.find(params[:id])
    @organizations = Organization.where(organization_type_id: @organization_type.id)
    if @organizations.count > 0
      flash.now[:danger] = "Cannot delete organization type, it is attached to an organization"
      render :edit
    else
      @organization_type.destroy
      flash[:success] = "organization type deleted"
      redirect_to organization_types_path
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
  def organization_type_params
    params.require(:organization_type).permit(:name)
  end
end
