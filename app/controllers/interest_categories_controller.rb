class InterestCategoriesController < ApplicationController
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /interests/1
  # GET /interests/1.json
  def show
    @interest_category = InterestCategory.find(params[:id])
  end

  # GET /interests/new
  def new
    @interest_category = InterestCategory.new
  end

  # GET /interests/1/edit
  def edit
    @interest_category = InterestCategory.find(params[:id])
  end

  def index
    @interest_categories = InterestCategory.paginate(page: params[:page])
  end

  # POST /interests
  # POST /interests.json
  def create
    @interest_category = InterestCategory.new(interest_category_params)
    if @interest_category.save
      redirect_to interest_categories_path, notice: 'interest category was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /interests/1
  # PATCH/PUT /interests/1.json
  def update
    @interest_category = InterestCategory.find(params[:id])
    if @interest_category.update_attributes(interest_category_params)
      flash[:success] = "interest category updated"
      redirect_to interest_categories_path
    else
      render :edit
    end
  end

  # DELETE /interests/1
  # DELETE /interests/1.json
  def destroy
    InterestCategory.find(params[:id]).destroy
    flash[:success] = "interest category deleted"
    redirect_to interest_categories_path
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
  def interest_category_params
    params.require(:interest_category).permit(:name)
  end
end
