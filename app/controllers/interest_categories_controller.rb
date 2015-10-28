include ApplicationHelper

class InterestCategoriesController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /interest_categories/1
  # GET /interest_categories/1.json
  def show
    @object = InterestCategory.find(params[:id])
  end

  # GET /interest_categories/new
  def new
    @object = InterestCategory.new
    render 'shared/simple_new'
  end

  # GET /interest_categories/1/edit
  def edit
    @object = InterestCategory.find(params[:id])
    render 'shared/simple_edit'
  end

  def index
    @objects = InterestCategory.paginate(page: params[:page])
    render 'shared/simple_index'
  end

  # POST /interest_categories
  # POST /interest_categories.json
  def create
    standard_new(InterestCategory, interest_category_params)
  end

  # PATCH/PUT /interest_categories/1
  # PATCH/PUT /interest_categories/1.json
  def update
    standard_update(InterestCategory, params[:id], interest_category_params)
  end


  # DELETE /interest_categories/1
  # DELETE /interest_categories/1.json
  def destroy
    standard_delete(InterestCategory, params[:id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def interest_category_params
    params.require(:interest_category).permit(:name)
  end
end
