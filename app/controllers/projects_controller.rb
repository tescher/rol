class ProjectsController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy]
  before_action :logged_in_admin_user, only: [:new, :edit, :update, :destroy, :import, :import_form]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.order(:name).all
    if (!defined? NO_PAGINATION) || !NO_PAGINATION
      @projects = @projects.paginate(page: params[:page])
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to projects_path, notice: 'project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(project_params)
      flash[:success] = "project updated"
      redirect_to projects_path
    else
      render :edit
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @projects = Workday.where(project_id: @project.id)
    if @projects.count > 0
      flash.now[:danger] = "Cannot delete project, it is attached to a workday"
      render :edit
    else
      @project.destroy
      flash[:success] = "project deleted"
      redirect_to projects_path
    end
  end

  # GET /projects/import
  def import_form
    render :import
  end

  # PUT /projects/import
  def import
    sequence = 0
    @records_read = 0
    @records_validated = 0
    @records_imported = 0
    @messages = []
    if params[:datafile].blank?
      @messages << "No file entered"
    else
      datafile = File.join(Rails.root, "app", "import", params[:datafile])
      validate_only = params[:validate_only]
      begin
        File.open( datafile ) do |file|

          doc = Nokogiri::Slop(file)

          doc.xpath("//record").each do |record|
            sequence += 1
            @records_read += 1
            fatal = false
            record_data = {}
            record_data["old_id"] = record.xpath("old_id").inner_text
            record_data["name"] = record.xpath("name").inner_text
            record_data["description"] = record.xpath("description").inner_text
            record_data["inactive"] = record.xpath("inactive").inner_text
            message_data = "Sequence: #{sequence}, Old ID: #{record_data["old_id"]}, Name: #{record_data["name"]}, Description: #{record_data["description"]}"
            if record_data["old_id"].blank?
              fatal = true
              @messages << "Missing id from old system. #{message_data}"
            else
              if !(Project.find_by_old_id(record_data["old_id"]).nil?)
                fatal = true
                @messages << "Imported previously. #{message_data}"
              else
                @project = Project.new

                record_data.each do |key, value|
                  if !value.blank?
                    @project[key] = (key == "inactive") ? ((value == "1") ? true : false) : value
                  end
                end
                if !@project.valid?
                  @messages << "Validation errors. #{message_data}"
                  @project.errors.full_messages.each do |message|
                    @messages << " -- #{message}"
                  end
                  fatal = true
                end
              end
            end
            if !fatal
              @records_validated += 1
              if !validate_only
                begin
                  @project.save
                  @records_imported += 1
                rescue => ex
                  @messages << "Save error. #{message_data}"
                  @messages << " -- #{ex.message}"
                end

              end
            end
          end
        end
      rescue => ex
        @messages << "#{ex.message}"
      end
    end

    render "shared/import_results"

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

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :description, :inactive)
  end
end
