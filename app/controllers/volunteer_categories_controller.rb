include ApplicationHelper

class VolunteerCategoriesController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /volunteer_categories/1
  # GET /volunteer_categories/1.json
  def show
    @object = VolunteerCategory.find(params[:id])
  end

  # GET /volunteer_categories/new
  def new
    @object = VolunteerCategory.new
    render 'shared/simple_new'
  end

  # GET /volunteer_categories/1/edit
  def edit
    @object = VolunteerCategory.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    standard_index(VolunteerCategory, params[:page])
  end

  # POST /volunteer_categories
  # POST /volunteer_categories.json
  def create
    standard_create(VolunteerCategory, volunteer_category_params)
  end

  # PATCH/PUT /volunteer_categories/1
  # PATCH/PUT /volunteer_categories/1.json
  def update
    standard_update(VolunteerCategory, params[:id], volunteer_category_params)
  end


  # DELETE /volunteer_categories/1
  # DELETE /volunteer_categories/1.json
  def destroy
    standard_destroy(VolunteerCategory, params[:id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def volunteer_category_params
    params.require(:volunteer_category).permit(:name, :inactive)
  end

end
