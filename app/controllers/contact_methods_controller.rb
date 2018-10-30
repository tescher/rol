include ApplicationHelper

class ContactMethodsController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]

  # GET /contact_methods/1
  # GET /contact_methods/1.json
  def show
    @object = ContactMethod.find(params[:id])
  end

  # GET /contact_methods/new
  def new
    @object = ContactMethod.new
    render 'shared/simple_new'
  end

  # GET /contact_methods/1/edit
  def edit
    @object = ContactMethod.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    standard_index(ContactMethod, params[:page])
  end

  # POST /contact_methods
  # POST /contact_methods.json
  def create
    standard_create(ContactMethod, contact_method_params)
  end

  # PATCH/PUT /contact_methods/1
  # PATCH/PUT /contact_methods/1.json
  def update
    standard_update(ContactMethod, params[:id], contact_method_params)
  end


  # DELETE /contact_methods/1
  # DELETE /contact_methods/1.json
  def destroy
    standard_destroy(ContactMethod, params[:id])
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_method_params
      params.require(:contact_method).permit(:name, :inactive)
    end
end
