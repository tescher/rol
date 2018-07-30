include ApplicationHelper

class InterestsController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /interests/1
  # GET /interests/1.json
  def show
    @object = Interest.find(params[:id])
  end

  # GET /interests/new
  def new
    @object = Interest.new
    render 'shared/simple_new'
  end

  # GET /interests/1/edit
  def edit
    @object = Interest.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    standard_index(Interest, params[:page])
  end

  # POST /interests
  # POST /interests.json
  def create
    standard_create(Interest, interest_params)
  end

  # PATCH/PUT /interests/1
  # PATCH/PUT /interests/1.json
  def update
    standard_update(Interest, params[:id], interest_params)
  end

  # DELETE /interests/1
  # DELETE /interests/1.json
  def destroy
    standard_destroy(Interest, params[:id])
    #if Volunteer.joins(:volunteer_interests).where(volunteer_interests: {interest_id: @interest.id}).count > 0
  end
  
  private
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def interest_params
    params.require(:interest).permit(:name, :interest_category_id, :highlight, :include_on_application, :inactive)
  end



end
