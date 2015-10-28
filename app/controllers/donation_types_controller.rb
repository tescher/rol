include ApplicationHelper

class DonationTypesController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /contact_types/1
  # GET /contact_types/1.json
  def show
    @object = DonationType.find(params[:id])
  end

  # GET /contact_types/new
  def new
    @object = DonationType.new
    render 'shared/simple_new'
  end

  # GET /contact_types/1/edit
  def edit
    @object = DonationType.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    @objects = DonationType.paginate(page: params[:page])
    render 'shared/simple_index'
  end

  # POST /contact_types
  # POST /contact_types.json
  def create
    standard_new(DonationType, contact_type_params)
  end

  # PATCH/PUT /contact_types/1
  # PATCH/PUT /contact_types/1.json
  def update
    standard_update(DonationType, params[:id], contact_type_params)
  end


  # DELETE /contact_types/1
  # DELETE /contact_types/1.json
  def destroy
    standard_delete(DonationType, params[:id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def donation_type_params
    params.require(:donation_type).permit(:name, :non_monetary, :inactive)
  end
end
