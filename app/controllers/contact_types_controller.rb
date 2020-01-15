include ApplicationHelper

class ContactTypesController < ApplicationController
  before_action { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /contact_types/1
  # GET /contact_types/1.json
  def show
    @object = ContactType.find(params[:id])
  end

  # GET /contact_types/new
  def new
    @object = ContactType.new
    render 'shared/simple_new'
  end

  # GET /contact_types/1/edit
  def edit
    @object = ContactType.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    standard_index(ContactType, params[:page])
  end

  # POST /contact_types
  # POST /contact_types.json
  def create
    standard_create(ContactType, contact_type_params)
  end

  # PATCH/PUT /contact_types/1
  # PATCH/PUT /contact_types/1.json
  def update
    standard_update(ContactType, params[:id], contact_type_params)
  end


  # DELETE /contact_types/1
  # DELETE /contact_types/1.json
  def destroy
    standard_destroy(ContactType, params[:id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def contact_type_params
    params.require(:contact_type).permit(:name, :inactive)
  end

end
