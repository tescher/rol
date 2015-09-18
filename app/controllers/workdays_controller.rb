class WorkdaysController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search, :report, :add_participants, :workday_summary]

  # GET /workdays
  # GET /workdays.json
  def index
    @workdays = Workday.where(project_id: params[:project_id]).order(workdate: :desc).paginate(page: params[:page])
    @project = Project.find(params[:project_id])
  end

  def report
    if !params[:report_type].nil?    # Will render report form on initial get

      if params[:request_format] == "xls"
        per_page = 1000000   #Hopefully all of them!
        request.format = :xls
      else
        per_page = 30
      end

      where_clause = ""

      if !params[:from_date].empty?
        where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
        where_clause += "workdate >= '#{Date.strptime(params[:from_date], "%m/%d/%Y").to_s}'"
      end
      if !params[:to_date].empty?
        where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
        where_clause += "workdate <= '#{Date.strptime(params[:to_date], "%m/%d/%Y").to_s}'"
      end

      project_ids = params[:project_ids].nil? ? [] : params[:project_ids]
      if project_ids.count > 0
        @project_info = Workday.select("COUNT(DISTINCT workday_volunteers.volunteer_id) as num_volunteers, COUNT(DISTINCT workdays.id) as num_workdays, SUM(workday_volunteers.hours) as total_hours, workdays.project_id").joins(:workday_volunteers).where(project_id: project_ids).where(where_clause).group(:project_id)
        if params[:report_type] == "1"
          @workdays = Workday.select("workdays.*, COUNT(workday_volunteers.id) as volunteers, COALESCE(SUM(workday_volunteers.hours), 0) as hours").joins(:workday_volunteers).where(where_clause).where(project_id: project_ids).order(:project_id).group("workdays.id")
        else
          @volunteers = Workday.select("workdays.project_id, workday_volunteers.volunteer_id, COALESCE(SUM(workday_volunteers.hours), 0) as hours").joins(:workday_volunteers).where(where_clause).where(project_id: project_ids).group("workday_volunteers.volunteer_id, workdays.project_id").order("hours DESC")
        end

      else
        @project_info = Workday.select("COUNT(DISTINCT workday_volunteers.volunteer_id) as num_volunteers, COUNT(DISTINCT workdays.id) as num_workdays, SUM(workday_volunteers.hours) as total_hours, workdays.project_id").joins(:workday_volunteers).where(where_clause).group(:project_id)
        if params[:report_type] == "1"
          @workdays = Workday.select("workdays.*, COUNT(workday_volunteers.id) as volunteers, SUM(workday_volunteers.hours) as hours").joins(:workday_volunteers).where(where_clause).order(:project_id).group("workdays.id")
        else
          @volunteers = Workday.select("workdays.project_id, workday_volunteers.volunteer_id, COALESCE(SUM(workday_volunteers.hours), 0) as hours").joins(:workday_volunteers).where(where_clause).group("workday_volunteers.volunteer_id, workdays.project_id").order("hours DESC")
        end
      end


      respond_to do |format|
        format.html {
          if params[:report_type] == "1"
            render "report_workdays_by_project.html"
          else
            render "report_volunteers_by_project.html"
          end

        }
        format.xls {
          response.headers['Content-Disposition'] = 'attachment; filename="report.xls"'
          if params[:report_type] == "1"
            render "report_workdays_by_project.xls"
          else
            render "report_volunteers_by_project.xls"
          end
        }


      end
    end

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
      redirect_to add_participants_workday_path({id: @workday.id, project_id: @project.id})
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
      if workday_params[:name].nil?         # Coming from Add Participants
        flash[:success] = "Workday updated"
        session.delete(:workday_id)
        redirect_to workdays_path(project_id: @workday.project_id)
      else
        redirect_to add_participants_workday_path(@workday)
      end
    else
      if workday_params[:name].nil?         # Coming from Add Participants
        render :add_participants
      else
        render :edit
      end
    end
  end

  def add_participants
    @workday = Workday.find(params[:id])
    session[:workday_id] = @workday.id
    @project = Project.find(@workday.project_id)
  end

  def workday_summary
    @objectName = params[:object_name].downcase
    if (@objectName != "volunteer") && (@objectName != "organization")
      render partial: "Invalid parameter"
    else
    @object = (@objectName == "volunteer") ? Volunteer.find(params[:id]) : Organization.find(params[:id])
    join = "INNER JOIN workday_#{@objectName}s ON workday_#{@objectName}s.workday_id = workdays.id"
    @workday_years = Workday.select("ROUND(EXTRACT(YEAR FROM workdays.workdate)) as year").joins(join).where("workday_" + @objectName + "s." + @objectName + "_id = '#{@object.id}'").group("year").order("year DESC")
    @workdays_by_year = Hash[@workday_years.map { |wy|
      year = wy.year.to_s.split(".").first
      workdays = Workday.select("DISTINCT workdays.*, SUM(workday_" + @objectName + "s.hours) as hours").joins(join).where("ROUND(EXTRACT(YEAR FROM workdate)) = '#{wy.year}'").group("workdays.id").order("workdate DESC")
      [year, workdays]
                             }]
    render partial: "dialog_workday_summary"
    end
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
    modified_params = params.require(:workday).permit(:name, :project_id, :workdate, workday_volunteers_attributes: [:id, :volunteer_id, :workday_id, :start_time, :start_time_string, :end_time, :end_time_string, :hours, :_destroy], workday_organizations_attributes: [:id, :organization_id, :workday_id, :start_time, :start_time_string, :end_time, :end_time_string, :hours, :num_volunteers, :_destroy])
    if modified_params[:workdate]
      modified_params[:workdate] = Date.strptime(modified_params[:workdate], "%m/%d/%Y").to_s
    end
    modified_params
  end
end
