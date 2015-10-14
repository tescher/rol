class ContactTypesController < ApplicationController
  before_action :logged_in_admin_user, only: [:index, :new, :edit, :update, :destroy]


  # GET /contact_types/1
  # GET /contact_types/1.json
  def show
    @contact_type = ContactType.find(params[:id])
  end

  # GET /contact_types/new
  def new
    @contact_type = ContactType.new
  end

  # GET /contact_types/1/edit
  def edit
    @contact_type = ContactType.find(params[:id])
  end

  def index
    @contact_types = ContactType.paginate(page: params[:page])
  end

  # POST /contact_types
  # POST /contact_types.json
  def create
    @contact_type = ContactType.new(contact_type_params)
    if @contact_type.save
      redirect_to contact_types_path, notice: 'contact type was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /contact_types/1
  # PATCH/PUT /contact_types/1.json
  def update
    @contact_type = ContactType.find(params[:id])
    if @contact_type.update_attributes(contact_type_params)
      flash[:success] = "contact type updated"
      redirect_to contact_types_path
    else
      render :edit
    end
  end


  # DELETE /contact_types/1
  # DELETE /contact_types/1.json
  def destroy
    @contact_type = ContactType.find(params[:id])
    @volunteers = Volunteer.where(first_contact_type_id: @contact_type.id)
    if @volunteers.count > 0
      flash.now[:danger] = "Cannot delete contact type, it is attached to a volunteer"
      render :edit
    else
      @contact_type.destroy
      flash[:success] = "contact type deleted"
      redirect_to contact_types_path
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
  def contact_type_params
    params.require(:contact_type).permit(:name, :inactive)
  end
end
