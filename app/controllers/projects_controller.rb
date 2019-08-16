include ApplicationHelper

class ProjectsController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy]
  before_action :logged_in_admin_user, only: [:new, :edit, :update, :destroy, :import, :import_form, :merge, :merge_form]

  # GET /projects
  # GET /projects.json
  def index
    standard_index(Project, params[:page], false, "", :name)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
    @object = Project.new
    render 'shared/simple_new'
  end

  # GET /projects/1/edit
  def edit
    @object = Project.find(params[:id])
    render 'shared/simple_edit'
  end

  # POST /projects
  # POST /projects.json
  def create
    standard_create(Project, project_params)
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    standard_update(Project, params[:id], project_params)
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    standard_destroy(Project, params[:id])
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

  def merge_form
    render :merge
  end

  # POST /projects/merge
  def merge
    if params[:project_id].blank?
      flash[:error] = "No project specified"
      render :merge
    else
      pid = params[:project_id]
      if Project.find_by_id(pid).nil?
        flash[:error] = "Project not found"
        render :merge
      else
        if params[:merge_project_ids].blank?
          flash[:error] = "No project(s) to merge specified"
          render :merge
        else
          if params[:merge_project_ids].include?(pid)
            flash[:error] = "Can't merge into same project"
            render :merge
          else
            params[:merge_project_ids].each do |mid|
              Workday.where(project_id: mid).each do |wd|
                wd.old_project_id = mid
                wd.project_id = pid
                wd.skip_dup_check = true
                wd.save!
              end
              if params[:mark_inactive] == "1"
                project = Project.find(mid)
                project.inactive = true
                project.save!
              end
            end

            flash[:success] = "Projects merged"
            redirect_to root_path
          end
        end
      end
    end
  end




  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :description, :inactive)
  end
end
