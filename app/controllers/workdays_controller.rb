include ApplicationHelper

class WorkdaysController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search, :report, :add_participants, :confirm_launch_self_tracking, :launch_self_tracking, :workday_summary, :participant_report, :update_projects_select]
  before_action :admin_user,     only: [:import, :import_form]


  # GET /workdays
  # GET /workdays.json
  def index
    @workdays = Workday.where(project_id: params[:project_id]).order(workdate: :desc)
    if (!defined? Utilities::Utilities.system_setting(:no_pagination)) || !Utilities::Utilities.system_setting(:no_pagination)
      @workdays = @workdays.paginate(page: params[:page])
    end
    @project = Project.find(params[:project_id])
  end

  def report
    if !params[:report_type].nil?    # Will render report form on initial get

      if params[:report_format] == "2"
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

      # For Volunteer Categories do a where similar to this on volunteer_category_volunteers table joined in "join" below on workday_volunteer.id
      volunteer_category_ids = params[:volunteer_category_ids].nil? ? [] : params[:volunteer_category_ids]
      if volunteer_category_ids.count > 0
        vc_where = "volunteer_category_id IN (" + volunteer_category_ids.join(",") + ")"
      else
        vc_where = "TRUE"
      end

      project_ids = params[:project_ids].nil? ? [] : params[:project_ids]
      if project_ids.count > 0
        project_where = "project_id IN (" + project_ids.join(",") + ")"
      else
        project_where = "project_id IS NOT NULL"
      end
      if !(vc_where == "TRUE")
        # join_volunteers = "JOIN workday_volunteers (JOIN volunteer_category_volunteers ON volunteer_category_volunteers.volunteer_id = workday_volunteer.volunteer_id) ON workdays.id = workday_volunteers.workday_id "
        join_volunteers = "JOIN workday_volunteers ON workdays.id = workday_volunteers.workday_id JOIN volunteer_category_volunteers ON volunteer_category_volunteers.volunteer_id = workday_volunteers.volunteer_id"
      else
        join_volunteers = "JOIN workday_volunteers ON workdays.id = workday_volunteers.workday_id "
      end
      join_organizations = "JOIN workday_organizations ON workdays.id = workday_organizations.workday_id "
      @report_info_volunteers = Workday.select("COALESCE(COUNT(DISTINCT workday_volunteers.volunteer_id), 0) as num_volunteers, COALESCE(COUNT(workday_volunteers.id), 0) as num_shifts, COALESCE(SUM(workday_volunteers.hours), 0) as volunteer_hours, '1' as id").joins(join_volunteers).where(project_where).where(where_clause).where(vc_where)
      @report_info_organizations = Workday.select("COALESCE(COUNT(DISTINCT workday_organizations.organization_id), 0) as num_organizations, COALESCE(SUM(workday_organizations.hours * workday_organizations.num_volunteers), 0) as organization_hours, '1' as id").joins(join_organizations).where(project_where).where(where_clause)
      #@report_info_volunteers = ApplicationRecord.connection.exec_query(report_info_volunteers_sql)
      #@report_info_organizations = ApplicationRecord.connection.exec_query(report_info_organizations_sql)
      logger.info "Report Info"
      @report_info = consolidate(@report_info_volunteers, @report_info_organizations)[0]
      logger.info "Consoliated Report: " + @report_info.to_yaml
      @project_info_volunteers = Workday.select("COALESCE(COUNT(DISTINCT workday_volunteers.volunteer_id), 0) as num_volunteers, COUNT(workday_volunteers.id) as num_shifts, COALESCE(SUM(workday_volunteers.hours), 0) as volunteer_hours, workdays.project_id, workdays.project_id as id").joins(join_volunteers).where(project_where).where(where_clause).where(vc_where).group(:project_id)
      @project_info_organizations = Workday.select("COALESCE(COUNT(DISTINCT workday_organizations.organization_id), 0) as num_organizations, COALESCE(SUM(workday_organizations.hours * workday_organizations.num_volunteers), 0) as organization_hours, workdays.project_id, workdays.project_id as id").joins(join_organizations).where(project_where).where(where_clause).group(:project_id)
      logger.info "Project Info"
      @project_info = consolidate(@project_info_volunteers, @project_info_organizations)
      logger.info "Consoliated Project: " + @project_info.to_yaml
      case params[:report_type]
      when "1"
        @workdays_volunteers = Workday.select("workdays.*, COALESCE(COUNT(workday_volunteers.id), 0) as num_volunteers, COALESCE(SUM(workday_volunteers.hours), 0) as volunteer_hours").joins(join_volunteers).where(where_clause).where(project_where).where(vc_where).order(:project_id).group("workdays.id")
        @workdays_organizations = Workday.select("workdays.*, COALESCE(COUNT(DISTINCT workday_organizations.organization_id), 0) as num_organizations, COALESCE(SUM(workday_organizations.hours * workday_organizations.num_volunteers), 0) as organization_hours").joins(join_organizations).where(where_clause).where(project_where).order(:project_id).group("workdays.id")
        # Put workdays together into one collection
        logger.info "Workday Info"
        @workdays = consolidate(@workdays_volunteers, @workdays_organizations)
      when "2"
        @volunteers = Workday.select("workdays.project_id, workday_volunteers.volunteer_id, COALESCE(SUM(workday_volunteers.hours), 0) as hours").joins(join_volunteers).where(where_clause).where(project_where).where(vc_where).group("workday_volunteers.volunteer_id, workdays.project_id").order("hours DESC")
        @organizations = Workday.select("workdays.project_id, workday_organizations.organization_id, COALESCE(SUM(workday_organizations.hours * workday_organizations.num_volunteers), 0) as hours").joins(:workday_organizations).where(where_clause).where(project_where).group("workday_organizations.organization_id, workdays.project_id").order("hours DESC")
      when "3"
        @volunteers = Workday.select("workday_volunteers.volunteer_id, COALESCE(SUM(workday_volunteers.hours), 0) as hours").joins(join_volunteers).where(where_clause).where(project_where).where(vc_where).group("workday_volunteers.volunteer_id").order("hours DESC")
        @organizations = Workday.select("workday_organizations.organization_id, COALESCE(SUM(workday_organizations.hours * workday_organizations.num_volunteers), 0) as hours").joins(:workday_organizations).where(where_clause).where(project_where).group("workday_organizations.organization_id").order("hours DESC")
      end

      respond_to do |format|
        format.html {
          case params[:report_type]
          when "1"
            render "report_workdays_by_project.html"
          when "2"
            render "report_participants_by_project.html"
          when "3"
            render "report_hours_by_participant.html"
          end

        }
        format.xls {
          response.headers['Content-Disposition'] = 'attachment; filename="report.xls"'
          case params[:report_type]
          when "1"
            render "report_workdays_by_project.xls"
          when "2"
            render "report_participants_by_project.xls"
          when "3"
            render "report_hours_by_participant.xls"
          end
        }


      end
    else
      @report_types = [["Workdays by Project",1], ["Participants by Project",2], ["Hours by Participant",3]]
      @report_format = [["Screen",1],["Excel",2]]
    end

  end

  # GET /workdays/1
  # GET /workdays/1.json
  def show
  end

  # GET /workdays/search
  def search
    @projects = Project.active.order(:name).all
    if (!defined? Utilities::Utilities.system_setting(:no_pagination)) || !Utilities::Utilities.system_setting(:no_pagination)
      @projects = @projects.paginate(page: params[:page])
    end
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

  # GET /workdays/import
  def import_form
    render :import
  end

  # PUT /workdays/import
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
            record_data["notes"] = record.xpath("notes").inner_text
            record_data["project_old_id"] = record.xpath("project_old_id").inner_text
            record_data["workdate"] = record.xpath("workdate").inner_text
            message_data = "Sequence: #{sequence}, Old ID: #{record_data["old_id"]}, Name: #{record_data["name"]}, Project Old ID: #{record_data["project_old_id"]}"
            if record_data["old_id"].blank?
              fatal = true
              @messages << "Missing id from old system. #{message_data}"
            else
              if record_data["project_old_id"].blank?
                fatal = true
                @messages << "Missing project id from old system. #{message_data}"
              else
                if !(Workday.find_by_old_id(record_data["old_id"]).nil?)
                  fatal = true
                  @messages << "Imported previously. #{message_data}"
                else
                  @project = Project.find_by_old_id(record_data["project_old_id"])
                  if (@project.nil?)
                    fatal = true
                    @messages << "Project not found. #{message_data}"
                  else
                    @workday = Workday.new

                    record_data.each do |key, value|
                      if !value.blank?
                        if key == "project_old_id"
                          @workday["project_id"] = @project.id
                        else
                          @workday[key] = (key == "workdate") ? Date.strptime(value, "%m/%d/%Y") :value
                        end
                      end
                    end
                    @workday.skip_dup_check = true
                    if !@workday.valid?
                      @messages << "Validation errors. #{message_data}"
                      @workday.errors.full_messages.each do |message|
                        @messages << " -- #{message}"
                      end
                      fatal = true
                    end
                  end
                end
              end
            end
            if !fatal
              @records_validated += 1
              if !validate_only
                begin
                  @workday.save
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

  def add_participants
    @workday = Workday.find(params[:id])
    session[:workday_id] = @workday.id
    @project = Project.find(@workday.project_id)
  end

  def confirm_launch_self_tracking
    @workday = Workday.find(params[:id])
    session[:workday_id] = @workday.id
    @project = Project.find(@workday.project_id)
  end

  def workday_summary
    @objectName = params[:object_name].downcase
    @objectId = params[:id]
    if (@objectName != "volunteer") && (@objectName != "organization")
      render partial: "Invalid parameter"
    else
      @object = (@objectName == "volunteer") ? Volunteer.including_pending.find(@objectId) : Organization.find(@objectId)
      join = "INNER JOIN workday_#{@objectName}s ON workday_#{@objectName}s.workday_id = workdays.id"
      @workday_years = Workday.select("ROUND(EXTRACT(YEAR FROM workdays.workdate)) as year").joins(join).where("workday_" + @objectName + "s." + @objectName + "_id = '#{@object.id}'").group("year").order("year DESC")
      @workdays_by_year = Hash[@workday_years.map { |wy|
        year = wy.year.to_s.split(".").first
        workdays = Workday.select("DISTINCT workdays.*, SUM(workday_" + @objectName + "s.hours) as hours").joins(join).where("ROUND(EXTRACT(YEAR FROM workdate)) = '#{wy.year}' AND workday_" + @objectName + "s." + @objectName + "_id = '#{@object.id}'").group("workdays.id").order("workdate DESC")
        [year, workdays]
      }]
      @year_totals = Hash[@workdays_by_year.map { |y, ws|
        year_hours = 0
        ws.each do |w|
          year_hours += w.hours
        end
        [y, year_hours.round(1)]
      }]

      render partial: "dialog_workday_summary"
    end
  end

  def participant_report
    @objectName = params[:object_name].downcase
    @objectId = params[:object_id]
    if params[:dialog] == "true"
      render partial: "dialog_participant_report_form"
    else
      @summary_only = params[:summary_only].to_i
      @from_date = params[:from_date]
      @to_date = params[:to_date]
      @project_ids = params[:project_ids]
      if (@objectName != "volunteer") && (@objectName != "organization")
        render partial: "Invalid parameter"
      else
        @object = (@objectName == "volunteer") ? Volunteer.find(@objectId) : Organization.find(@objectId)

        date_where_clause = ""

        if !@from_date.empty?
          date_where_clause = date_where_clause.length > 0 ? date_where_clause + " AND " : date_where_clause
          date_where_clause += "workdate >= '#{Date.strptime(@from_date, "%m/%d/%Y").to_s}'"
        end
        if !params[:to_date].empty?
          date_where_clause = date_where_clause.length > 0 ? date_where_clause + " AND " : date_where_clause
          date_where_clause += "workdate <= '#{Date.strptime(@to_date, "%m/%d/%Y").to_s}'"
        end

        # Workdays involving this volunteer or org
        object_where_clause = "(workday_" + @objectName + "s." + @objectName + "_id = '#{@object.id}')"
        if @objectName == "volunteer"
          object_where_clause += " OR (donated_to_id = '#{@objectId}')"
        end

        project_ids = @project_ids.nil? ? [] : @project_ids
        if project_ids.count > 0
          project_where_clause = "project_id IN (" + project_ids.join(",") + ")"
        else
          project_where_clause = "project_id IS NOT NULL"
        end

        workday_where_clause = "workday_#{@objectName}s.workday_id = workdays.id"

        @workdays = Workday.from("workdays, workday_#{@objectName}s").select("workdays.*, workday_#{@objectName}s.*").where(workday_where_clause).where(object_where_clause).where(date_where_clause).where(project_where_clause).order("workdays.workdate")
        @workdays_by_project = @workdays.group_by(&:project_id).sort_by{|project_id, _extras| Project.find(project_id).name}
        puts @workdays_by_project.inspect
        puts @workdays_by_project.size
        render "report_participant_report"
      end
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

  def update_projects_select
    if params[:include_inactive] == "true"
      @projects = Project.all.order(:name)
    else
      @projects = Project.active.all.order(:name)
    end
    respond_to do |format|
      format.js
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def workday_params
    modified_params = params.require(:workday).permit(:name, :project_id, :workdate, :notes, workday_volunteers_attributes: [:id, :volunteer_id, :workday_id, :start_time, :start_time_string, :end_time, :end_time_string, :hours, :donated_to_id, :notes, :_destroy], workday_organizations_attributes: [:id, :organization_id, :workday_id, :start_time, :start_time_string, :end_time, :end_time_string, :hours, :num_volunteers, :notes, :_destroy])
    if modified_params[:workdate]
      modified_params[:workdate] = Date.strptime(modified_params[:workdate], "%m/%d/%Y").to_s
    end
    modified_params
  end

  # Consolidate two collections of workdays with volunteer and organization data
  def consolidate (collection1, collection2)
    logger.info "Collection1: " + collection1.inspect
    logger.info "Collection2: " + collection2.inspect
    #if collection1.nil? && collection2 then
    #return collection2
    #elsif collection1 && collection2.nil? then
    #return collection1
    #elsif collection1.nil? && collection2.nil? then
    #return []
    #end

    workdays = []
    if collection1
      collection1.each do |w|
        w1 = JSON.parse w.to_json
        if collection2
          w2 = (collection2.select { |wc| wc.id == w.id })[0]
          if !w2.nil?
            w2.attributes.each do | attr_name, attr_value |
              if !w1[attr_name].present?
                logger.info attr_name.to_s + ": " + attr_value.to_s
                w1[attr_name] = attr_value
              end
            end
          end
        end
        workdays.push w1
      end
    end
    if collection2
      collection2.each do |w2|
        w1 = (collection1.select { |wc| wc.id == w2.id })[0]
        if w1.nil?
          workdays.push JSON.parse w2.to_json
        end
      end
    end
    workdays_hashed = []
    workdays.each do |h|
      workdays_hashed.push h.symbolize_keys
    end
    workdays_hashed
  end
end
