include ApplicationHelper

class OrganizationTypesController < ApplicationController
  before_action { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /organization_types/1
  # GET /organization_types/1.json
  def show
    @object = OrganizationType.find(params[:id])
  end

  # GET /organization_types/new
  def new
    @object = OrganizationType.new
    render 'shared/simple_new'
  end

  # GET /organization_types/1/edit
  def edit
    @object = OrganizationType.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    standard_index(OrganizationType, params[:page])
  end

  # POST /organization_types
  # POST /organization_types.json
  def create
    standard_create(OrganizationType, organization_type_params)
  end

  # PATCH/PUT /organization_types/1
  # PATCH/PUT /organization_types/1.json
  def update
    standard_update(OrganizationType, params[:id], organization_type_params)
  end


  # DELETE /organization_types/1
  # DELETE /organization_types/1.json
  def destroy
    standard_destroy(OrganizationType, params[:id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def organization_type_params
    params.require(:organization_type).permit(:name, :inactive)
  end
end
