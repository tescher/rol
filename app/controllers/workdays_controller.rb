class WorkdaysController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search]

  # GET /workdays
  # GET /workdays.json
  def index
    @workdays = Workday.where(project_id: params[:project_id]).order(workdate: :desc).paginate(page: params[:page])
    @project = Project.find(params[:project_id])
  end

  # GET /workdays/1
  # GET /workdays/1.json
  def show
  end

  # GET /workdays/search
  def search
    @projects = Project.all
  end

  # GET /workdays/new
  def new
    @project = @project || Project.find(params[:project_id])
    @workday = Workday.new(project_id: @project.id)
  end

  # GET /workdays/1/edit
  def edit
    @workday = Workday.find(params[:id])
    @project = Project.find(@workday.project_id)
  end

  # POST /workdays
  # POST /workdays.json
  def create
    @project = Project.find(workday_params[:project_id])
    @workday = Workday.new(workday_params)
    if @workday.save
      redirect_to add_volunteers_workday_path({id: @workday.id, project_id: @project.id})
    else
      render :new
    end
  end

  # PATCH/PUT /workdays/1
  # PATCH/PUT /workdays/1.json
  def update
    @workday = Workday.find(params[:id])
    @project = Project.find(@workday.project_id)
    if @workday.update_attributes(workday_params)
      if workday_params[:name].nil?         # Coming from Add Volunteers
        flash[:success] = "Workday updated"
        session.delete(:workday_id)
        redirect_to workdays_path(project_id: @workday.project_id)
      else
        redirect_to add_volunteers_workday_path(@workday)
      end
    else
      if workday_params[:name].nil?         # Coming from Add Volunteers
        render :add_volunteers
      else
        render :edit
      end
    end
  end

  def add_volunteers
    @workday = Workday.find(params[:id])
    session[:workday_id] = @workday.id
    @project = Project.find(@workday.project_id)
  end


  # DELETE /workdays/1
  # DELETE /workdays/1.json
  def destroy
    @workday = Workday.find(params[:id])
    project_id = @workday.project_id
    @workday.destroy
    flash[:success] = "Workday deleted"
    redirect_to workdays_path(project_id: project_id)
  end

  private

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workday_params
      pp params
      modified_params = params.require(:workday).permit(:name, :project_id, :workdate, workday_volunteers_attributes: [:id, :volunteer_id, :workday_id, :start_time, :end_time, :hours, :_destroy])
      if modified_params[:workdate]
          modified_params[:workdate] = Date.strptime(modified_params[:workdate], "%m/%d/%Y").to_s
      end
      modified_params
    end
end
