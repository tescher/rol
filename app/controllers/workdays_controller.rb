class WorkdaysController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search]

  # GET /workdays
  # GET /workdays.json
  def index
    @workdays = Workday.where(project_id: params[:project_id]).order(created_at: :desc).paginate(page: params[:page])
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
    @project = Project.find(params[:project_id])
    @workday = Workday.new(project_id: @project.id)
  end

  # GET /workdays/1/edit
  def edit
    @workday = Workday.find(params[:id])
  end

  # POST /workdays
  # POST /workdays.json
  def create
    modified_params = workday_params
    @workday = Workday.new(modified_params)
    if @workday.save
      redirect_to workdays_path({project_id: modified_params[:project_id]}), notice: 'interest category was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /workdays/1
  # PATCH/PUT /workdays/1.json
  def update
    respond_to do |format|
      if @workday.update(workday_params)
        format.html { redirect_to @workday, notice: 'Workday was successfully updated.' }
        format.json { render :show, status: :ok, location: @workday }
      else
        format.html { render :edit }
        format.json { render json: @workday.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_volunteers

  end


  # DELETE /workdays/1
  # DELETE /workdays/1.json
  def destroy
    @workday.destroy
    respond_to do |format|
      format.html { redirect_to workdays_url, notice: 'Workday was successfully destroyed.' }
      format.json { head :no_content }
    end
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
      if params[:workday][:workdate]
          params[:workday][:workdate] = Date.strptime(params[:workday][:workdate], "%m/%d/%Y").to_s
      end
      params.require(:workday).permit(:name, :project_id, :workdate)
    end
end
