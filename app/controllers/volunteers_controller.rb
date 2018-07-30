include WorkdaysHelper
include DonationsHelper
include ApplicationHelper
include VolunteersHelper
include WaiversHelper

class VolunteersController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search, :address_check, :donations, :waivers, :merge, :search_merge, :merge_form]
  before_action :admin_user,     only: [:destroy, :import, :import_form]
  before_action :donations_allowed, only: [:donations]
  autocomplete :volunteer, :last_name, :full => true, :extra_data => [:first_name, :city], :display_value => :autocomplete_display


  def search
    if params[:dialog] == "true"
      @alias = params[:alias].blank? ? "" : params[:alias]
      render partial: "dialog_search_form"
    end
  end

  def address_check

    respond_to do |format|
      format.html {
        render partial: 'shared/dialog_address_checker'
      }
      format.json {
        address = Hash.new()
        address_json = JSON.parse(params[:address])
        address[:street] = address_json['street']
        address[:city] = address_json['city']
        address[:state] = address_json['state']
        address[:postal_code] = address_json['postal_code']
        fedex = Fedex::Shipment.new(:key => FEDEX_KEY,
                                    :password => FEDEX_PASSWORD,
                                    :account_number => FEDEX_ACCOUNT,
                                    :meter => FEDEX_METER,
                                    :mode => FEDEX_MODE)
        begin
          address_result = fedex.validate_address(address: address)
          render json: address_result
        rescue Fedex::RateError => error
          puts error
          puts address_result
        end
      }
    end
  end

  # GET /volunteers
  def index
    if params[:request_format] == "xls"
      per_page = 1000000   #Hopefully all of them!
      request.format = :xls
    else
      if params[:dialog] == "true"
        per_page = 1000000
      else
        per_page = 30
      end
    end
    where_clause = ""
    if params[:system_merge_match] == "true"
      @volunteers = find_matching_volunteers(Volunteer.find(session[:volunteer_id])).map {|id, mv| mv[:volunteer]}
    else
      if params[:show_all]
        @volunteers = Volunteer.select("DISTINCT(volunteers.id), volunteers.*").where(where_clause).order(:last_name, :first_name).paginate(page: params[:page], per_page: per_page)
      else
        if (volunteer_search_params.count < 1)
          @volunteers = Volunteer.none
        else
          # Parse name if comma entered, otherwise assume last name only
          search_params = volunteer_search_params
          if (search_params[:name] == "=")
            if (!session[:volunteer_id].nil?)
              @volunteers = Volunteer.where(id: session[:volunteer_id]).paginate(page: params[:page], per_page: per_page)
            else
              @volunteers = []
            end
          else
            if !search_params[:name].blank?
              names = search_params[:name].split(",")
              if !names[1].blank?
                search_params[:first_name] = names[1].lstrip
              end
              if !names[0].blank?
                search_params[:last_name] = names[0].lstrip
              end
              search_params = search_params.except(:name)
            end
            interest_ids = []
            volunteer_category_ids = []
            search_params.each do |index|
              if ["last_name", "first_name", "city"].include?(index[0])
                if index[1].strip.length > 0
                  where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
                  where_clause += Volunteer.get_fuzzymatch_where_clause(index[0], index[1])
                end
              end
              if index[0] == "interest_ids"
                interest_ids = index[1]
              end
              if index[0] == "volunteer_category_ids"
                volunteer_category_ids = index[1]
              end
            end

            joins_clause = []
            if interest_ids.count > 0
              joins_clause << :volunteer_interests
              where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
              where_clause += "volunteer_interests.interest_id IN (#{interest_ids.join(',')})"
            end
            if volunteer_category_ids.count > 0
              joins_clause << :volunteer_category_volunteers
              where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
              where_clause += "volunteer_category_volunteers.volunteer_category_id IN (#{volunteer_category_ids.join(',')})"
            end

            if !search_params[:workday_since].blank?
              workday_since = Date.strptime(search_params[:workday_since], "%m/%d/%Y").to_s
              if !workday_since.blank?
                joins_clause << :workday_volunteers
                joins_clause << :workdays
                where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
                where_clause += "workdays.workdate >= '#{workday_since}'"
                #@volunteers = @volunteers.joins(:workday_volunteers, :workdays).where("workday_volunteers.volunteer_id = '#{v.id}'").where("workdays.workdate >= '#{workday_since}'")
              end
            end
            @volunteers = Volunteer.select("DISTINCT(volunteers.id), volunteers.*").joins(joins_clause).where(where_clause).order(:last_name, :first_name).paginate(page: params[:page], per_page: per_page)
          end
        end
      end
      if params[:merge] == "true"  # If in merge flow, remove the volunteer we are working with
        @volunteers = @volunteers.to_a
        @volunteers.each do |v|
          if v.id == session[:volunteer_id]
            @volunteers.delete(v)
          end
        end
      end
    end

    if params[:merge_families] == "true"
      @volunteers_clean = @volunteers.deep_dup
      @volunteers_clean.map {|volunteer|
        volunteer.last_name = volunteer.last_name.delete("^a-zA-Z0-9").upcase
        if volunteer.address.present?
          volunteer.address = volunteer.address.delete("^a-zA-Z0-9").upcase
        end
        if volunteer.city.present?
          volunteer.city = volunteer.city.delete("^a-zA-Z0-9").upcase
        end
        volunteer
      }
      @volunteers_clean.sort_by {|rec| [rec.last_name.to_s, rec.address.to_s, rec.city.to_s]}
      prev_last_name = ""
      prev_address = ""
      prev_city = ""
      combined_first_name = ""
      prev_volunteer = nil
      @volunteers_filtered = []

      @volunteers_clean.each {|volunteer|
        if (prev_last_name != "") && (volunteer.last_name == prev_last_name) && (prev_address != "") && (volunteer.address == prev_address) && (prev_city != "") && (volunteer.city == prev_city)
          combined_first_name = volunteer.first_name + "/" + combined_first_name
          prev_volunteer = volunteer
        else
          if combined_first_name != ""
            new_volunteer = @volunteers.detect {|v| v.id == prev_volunteer.id}
            new_volunteer.first_name = combined_first_name
            @volunteers_filtered << new_volunteer
          end
          prev_volunteer = volunteer
          combined_first_name = volunteer.first_name
          prev_last_name = volunteer.last_name
          prev_address = volunteer.address
          prev_city = volunteer.city
        end
      }
      if !prev_volunteer.nil?
        new_volunteer = @volunteers.detect {|v| v.id == prev_volunteer.id}
        new_volunteer.first_name = combined_first_name
        @volunteers_filtered << new_volunteer
      end
      @volunteers = @volunteers_filtered
    end

    @last_workdate = {}
    @volunteers.each do |v|
      last_workday = Workday.joins(:workday_volunteers).where("workday_volunteers.volunteer_id = '#{v.id}'").order("workdays.workdate DESC").first
      if !last_workday.nil?
        @last_workdate[v.id] = last_workday.workdate
      end
    end

    respond_to do |format|
      format.html {
        if params[:dialog] == "true"
          if params[:merge] == "true"
            render partial: "dialog_index_merge"
          else
            @alias = params[:alias].blank? ? "" : params[:alias]
            render partial: "dialog_index"
          end
        else
          render :index
        end
      }
      format.xls {
        response.headers['Content-Disposition'] = 'attachment; filename="volunteers.xls"'
        render "index.xls"
      }
    end
  end

  # GET /volunteers/1
  # GET /volunteers/1.json
  def show
    @volunteer = Volunteer.find(params[:id])
  end

  # GET /volunteers/new
  def new
    @volunteer = Volunteer.new
    @num_workdays = []
    if params[:dialog] == "true"
      @alias = params[:alias].blank? ? "" : params[:alias]
      render partial: "dialog_form"
    else
      @allow_stay = true
      session[:volunteer_id] = @volunteer.id
      if params[:pending_volunteer_id]
        @pending_volunteer = Volunteer.pending.find(params[:pending_volunteer_id])
        @num_workdays = WorkdayVolunteer.where(volunteer_id: params[:pending_volunteer_id])
        @volunteer.pending_volunteer_id = @pending_volunteer.id
        ["first_name", "last_name", "address", "city", "state", "zip", "phone", "email", "occupation", "emerg_contact_phone", "emerg_contact_name", "notes", "limitations", "medical_conditions", "agree_to_background_check", "interests"].each do |column|
          if column == "phone"
            @volunteer.send("home_phone=", @pending_volunteer.send(column))
          else
            @volunteer.send(column+"=", @pending_volunteer.send(column))
          end
        end
      end
    end
  end

  # GET /volunteers/1/edit
  def edit
    edit_setup
  end

  # POST /volunteers
  # POST /volunteers.json
  def create
    # If coming from the pending volunteer flow, we convert the original pending
    # volunteer record.
    if volunteer_params[:pending_volunteer_id].present?
      from_pending_volunteers = true
      @volunteer = Volunteer.pending.find(volunteer_params[:pending_volunteer_id])
      @volunteer.needs_review = false
      @volunteer.assign_attributes(volunteer_params)
    else
      from_pending_volunteers = false
      @volunteer = Volunteer.new(volunteer_params)
    end

    if @volunteer.save    # Save successful
      session[:volunteer_id] = @volunteer.id
      if params[:volunteer][:dialog] == "true"
        @workday = session[:workday_id]
        @alias = params[:volunteer][:alias].blank? ? "" : params[:volunteer][:alias]
        render partial: "dialog_add_child_fields"
      else
        flash[:success] = "Volunteer created"
        if !params[:to_donations].blank?
          session[:child_entry] = "donations"
          redirect_to donations_volunteer_path(@volunteer)
        else
          if !params[:to_waivers].blank?
            session[:child_entry] = "waivers"
            redirect_to waivers_volunteer_path(@volunteer)
          else
            session[:child_entry] = nil
            if params[:stay].blank?
              if from_pending_volunteers
                redirect_to pending_volunteers_path
              else
                redirect_to search_volunteers_path
              end
            else
              redirect_to edit_volunteer_path(@volunteer)
            end
          end
        end
      end
    else                 # Save not successful
      if params[:volunteer][:dialog] == "true"
        @alias = params[:alias].blank? ? "" : params[:alias]
        render partial: "dialog_form"
      else
        @num_workdays = []
        @allow_stay = true
        render :new
      end
    end
  end

  # PATCH/PUT /volunteers/1
  # PATCH/PUT /volunteers/1.json
  def update
    @volunteer = Volunteer.find(params[:id])
    session[:volunteer_id] = @volunteer.id
    from = session[:child_entry]

    if !from.nil?     # Coming from donations or waivers
      if params[:volunteer] && @volunteer.update_attributes(volunteer_params)
        flash[:success] = "#{from.capitalize} updated"
        if from == "waivers"
          #Update last waiver date, birthdate and adult flag from last waiver if not already set
          @volunteer.reload
          last_waiver = last_waiver(@volunteer.id)
          puts last_waiver.to_yaml
          if !last_waiver.nil?
            if @volunteer.birthdate.nil? && last_waiver.birthdate
              @volunteer.birthdate = last_waiver.birthdate
            end
            if @volunteer.try(:adult) == false && last_waiver.adult
              @volunteer.adult = last_waiver.adult
            end
            if (@volunteer.waiver_date.nil?) || (last_waiver.date_signed > @volunteer.waiver_date)
              @volunteer.waiver_date = last_waiver.date_signed
            end
            @volunteer.save
          end
        end
        if !params[:stay].blank?
          if from == "donations"
            redirect_to donations_volunteer_path(@volunteer)
          else
            redirect_to waivers_volunteer_path(@volunteer)
          end
        else
          session[:child_entry] = nil
          if !params[:save_and_search].blank?
            redirect_to search_volunteers_path
          else
            redirect_to edit_volunteer_path(@volunteer)
          end
        end
      else
        if params[:volunteer]  # Save must have been unsuccessful
          child_form_setup
          if from == "donations"
            render "shared/donations_form"
          else
            render "waivers/waivers_form"
          end
        else       # Must have saved with no data
          session[:child_entry] = nil
          if !params[:save_and_search].blank?
            redirect_to search_volunteers_path
          else
            redirect_to edit_volunteer_path(@volunteer)
          end
        end
      end
    else                                       # Coming from regular edit
      if params[:volunteer] && @volunteer.update_attributes(volunteer_params)
        flash[:success] = "Volunteer updated"
        if !params[:to_donations].blank?
          session[:child_entry] = "donations"
          redirect_to donations_volunteer_path(@volunteer)
        else
          if !params[:to_waivers].blank?
            session[:child_entry] = "waivers"
            redirect_to waivers_volunteer_path(@volunteer)
          else
            session[:child_entry] = nil
            if params[:stay].blank?
              redirect_to search_volunteers_path
            else
              redirect_to edit_volunteer_path(@volunteer)
            end
          end
        end
      else
        edit_setup
        render :edit
      end
    end
  end

  def search_merge
    if params[:dialog] == "true"
      render partial: "dialog_search_merge_form"
    end
  end

  def merge_form
    @source_volunteer = Volunteer.find(params[:source_id])
    @object = Volunteer.find(params[:id])
    if @source_volunteer.nil? || @object.nil?
      redirect_to root_path
    end
    render :merge
  end

  # POST /volunteers/1/merge
  def merge
    @object =Volunteer.find(params[:id])
    if params[:source_id].blank?
      redirect_to root_path
    else
      @source_volunteer = Volunteer.find(params[:source_id])
      volunteer_params = {}
      if params[:source_use_fields] then
        params[:source_use_fields].each do |findex|
          item = Volunteer.merge_fields_table.key(findex.to_i)
          volunteer_params[item] = @source_volunteer[item]
        end
      end
      if (params[:use_notes].downcase != "ignore")
        if @object.notes.blank? || (params[:use_notes].downcase == "replace")
          volunteer_params[:notes] = @source_volunteer.notes
        else
          if (!@source_volunteer.notes.blank?)
            if (params[:use_notes].downcase == "append")
              volunteer_params[:notes] = @object.notes + "\n" + @source_volunteer.notes
            else
              if (params[:use_notes].downcase == "prepend")
                volunteer_params[:notes] =  @source_volunteer.notes + "\n" + @object.notes
              end
            end
          end
        end
      end
      if (params[:use_limitations].downcase != "ignore")
        if @object.limitations.blank? || (params[:use_limitations].downcase == "replace")
          volunteer_params[:limitations] = @source_volunteer.limitations
        else
          if (!@source_volunteer.limitations.blank?)
            if (params[:use_limitations].downcase == "append")
              volunteer_params[:limitations] = @object.limitations + "\n" + @source_volunteer.limitations
            else
              if (params[:use_limitations].downcase == "prepend")
                volunteer_params[:limitations] =  @source_volunteer.limitations + "\n" + @object.limitations
              end
            end
          end
        end
      end
      if (params[:use_medical_conditions].downcase != "ignore")
        if @object.medical_conditions.blank? || (params[:use_medical_conditions].downcase == "replace")
          volunteer_params[:medical_conditions] = @source_volunteer.medical_conditions
        else
          if (!@source_volunteer.medical_conditions.blank?)
            if (params[:use_medical_conditions].downcase == "append")
              volunteer_params[:medical_conditions] = @object.medical_conditions + "\n" + @source_volunteer.medical_conditions
            else
              if (params[:use_medical_conditions].downcase == "prepend")
                volunteer_params[:medical_conditions] =  @source_volunteer.medical_conditions + "\n" + @object.medical_conditions
              end
            end
          end
        end
      end

      # interests = []
      volunteer_interest_ids = VolunteerInterest.where("volunteer_id = #{@object.id}").map {|i| i.interest_id}
      source_interest_ids = VolunteerInterest.where("volunteer_id = #{@source_volunteer.id}").map {|i| i.interest_id}
      if (params[:use_interests].downcase != "ignore")
        if (params[:use_interests].downcase == "add")
          volunteer_params[:interest_ids] = (source_interest_ids + volunteer_interest_ids).uniq
        else
          volunteer_params[:interest_ids] = source_interest_ids.dup
        end
      end
      volunteer_category_volunteer_ids = VolunteerCategoryVolunteer.where("volunteer_id = #{@object.id}").map {|i| i.volunteer_category_id}
      source_volunteer_category_ids = VolunteerCategoryVolunteer.where("volunteer_id = #{@source_volunteer.id}").map {|i| i.volunteer_category_id}
      if (params[:use_categories].downcase != "ignore")
        if (params[:use_categories].downcase == "add")
          volunteer_params[:volunteer_category_ids] = (source_volunteer_category_ids +  volunteer_category_volunteer_ids).uniq
        else
          volunteer_params[:volunteer_category_ids] = source_volunteer_category_ids.dup
        end
      end

      if @object.update_attributes(volunteer_params)

        # If successful, move everything else
        WorkdayVolunteer.where("volunteer_id = #{@source_volunteer.id}").each do |sw|
          workday = sw.dup
          workday.volunteer_id = @object.id
          workday.save!
          sw.destroy!
        end
        Donation.where("volunteer_id = #{@source_volunteer.id}").each do |sd|
          donation = sd.dup
          donation.volunteer_id = @object.id
          donation.save!
          sd.destroy!
        end
        Waiver.where("volunteer_id = #{@source_volunteer.id}").each do |swv|
          waiver = swv.dup
          waiver.volunteer_id = @object.id
          waiver.save!
          swv.really_destroy!
        end

        @source_volunteer.deleted_reason = "Merged with #{@object.id}"
        @source_volunteer.save
        @source_volunteer.destroy!

        flash[:success] = "Volunteers merged"

        redirect_to edit_volunteer_path(@object)

      else
        @object.errors.each {|attr, error| @object.errors.add(attr, error)}
        @object.reload
        render :merge
      end

    end
  end

  # DELETE /volunteers/1
  # DELETE /volunteers/1.json
  def destroy
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.destroy
      flash[:success] = "Volunteer deleted"
      redirect_to search_volunteers_path
    else
      edit_setup
      render :edit
    end
  end

  # GET /volunteer/1/donations
  def donations
    child_form_setup
    render "shared/donations_form"
  end

  # GET /volunteer/1/waivers
  def waivers
    child_form_setup
    render "waivers/waivers_form"
  end

  # GET /volunteers/import
  def import_form
    render :import
  end

  # PUT /volunteers/import
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
            record_data["first_name"] = record.xpath("first_name").inner_text
            record_data["middle_name"] = record.xpath("middle_name").inner_text
            record_data["last_name"] = record.xpath("last_name").inner_text
            record_data["occupation"] = record.xpath("occupation").inner_text
            record_data["address"] = record.xpath("address").inner_text
            record_data["city"] = record.xpath("city").inner_text
            record_data["state"] = record.xpath("state").inner_text
            record_data["zip"] = record.xpath("zip").inner_text
            record_data["home_phone"] = record.xpath("home_phone").inner_text
            record_data["work_phone"] = record.xpath("work_phone").inner_text
            record_data["mobile_phone"] = record.xpath("mobile_phone").inner_text
            record_data["work_phone"] = record.xpath("work_phone").inner_text
            record_data["notes"] = record.xpath("notes").inner_text
            record_data["waiver_date"] = record.xpath("waiver_date").inner_text
            record_data["first_contact_date"] = record.xpath("first_contact_date").inner_text
            record_data["first_contact_type"] = record.xpath("first_contact_type").inner_text
            record_data["church_old_id"] = record.xpath("church_old_id").inner_text
            record_data["employer_old_id"] = record.xpath("employer_old_id").inner_text
            record_data["email"] = record.xpath("email").inner_text
            record_data["remove_from_mailing_list"] = record.xpath("remove_from_mailing_list").inner_text
            record_data_interests = []
            record.xpath("interests/*").each do |interest|
              if interest.inner_text == "1"
                record_data_interests << interest.name().gsub("_"," ")
              end
            end
            message_data = "Sequence: #{sequence}, Old ID: #{record_data["old_id"]}, First Name: #{record_data["first_name"]}, Last Name: #{record_data["last_name"]}"
            if record_data["old_id"].blank?
              fatal = true
              @messages << "Missing id from old system. #{message_data}"
            else
              if !(Volunteer.find_by_old_id(record_data["old_id"]).nil?)
                fatal = true
                @messages << "Imported previously. #{message_data}"
              else
                @church = nil
                if !record_data["church_old_id"].blank?
                  @church = Organization.find_by_old_id_and_organization_type_id(record_data["church_old_id"], 1)
                  if (@church.nil?)
                    @messages << "Church not found. #{message_data}"
                  end
                end
                @employer = nil
                if !record_data["employer_old_id"].blank?
                  @employer = Organization.find_by_old_id_and_organization_type_id(record_data["employer_old_id"], 2)
                  if (@employer.nil?)
                    @messages << "Employer not found. #{message_data}"
                  end
                end
                @contact_type = nil
                if !record_data["first_contact_type"].blank?
                  @contact_type = ContactType.where("name ilike ?", "%#{record_data["first_contact_type"]}").first
                  if (@contact_type.nil?)
                    fatal = true
                    @messages << "Missing #{record_data["first_contact_type"]} contact type mapping. #{message_data}"
                  end
                end
                interests = []
                record_data_interests.each do |interest_name|
                  interest = Interest.where("name ilike ?", "%#{interest_name}").first
                  if interest.nil?
                    @messages << "Missing #{interest_name} interest mapping. #{message_data}"
                    fatal = true
                  else
                    interests << interest
                  end
                end
              end
            end
            if !fatal
              @volunteer = Volunteer.new
              if !@church.nil?
                @volunteer.church_id = @church.id
              end
              if !@employer.nil?
                @volunteer.employer_id = @employer.id
              end
              if !@contact_type.nil?
                @volunteer.first_contact_type_id = @contact_type.id
              end
              if interests.count > 0
                @volunteer.interests = interests
              end
              record_data.each do |key, value|
                if (key != "notes") && (key != "church_old_id") && (key != "employer_old_id") && (key != "first_contact_type")
                  if !value.blank?
                    begin
                      @volunteer[key] = ((key == "waiver_date") || (key == "first_contact_date")) ? Date.strptime(value, "%m/%d/%Y") : value
                    rescue => ex
                      @messages << "Warning: Invalid " + key + " data (" + value + "), saved in notes field. #{message_data}"
                      @messages << " -- #{ex.message}"
                      record_data["notes"] += ". Invalid " + key + " data found in conversion: " + value
                    end
                  end
                end
              end
              if !@volunteer.valid?
                if @volunteer.errors[:email].any?
                  @messages << "Invalid email " + record_data["email"] + ", saved to notes"
                  record_data["notes"] += ". Invalid email found in conversion: " + record_data["email"]
                  @volunteer.email = ""
                else
                  @messages << "Validation errors. #{message_data}"
                  @volunteer.errors.full_messages.each do |message|
                    @messages << " -- #{message}"
                  end
                  fatal = true
                end
              end
              if !record_data["notes"].blank?
                @volunteer["notes"] = record_data["notes"]
              end
            end
            if !fatal
              @records_validated += 1
              if !validate_only
                begin
                  @volunteer.save
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :middle_name, :email, :occupation, :employer_id, :church_id,
                                      :address, :city, :state, :zip, :home_phone, :work_phone, :mobile_phone,
                                      :notes, :remove_from_mailing_list, :waiver_date, :birthdate, :adult, :first_contact_date, :first_contact_type_id, :pending_volunteer_id, :agree_to_background_check, :background_check_date, :emerg_contact_name, :emerg_contact_phone, :limitations, :medical_conditions, interest_ids: [], volunteer_category_ids: [], donations_attributes: [:id, :date_received, :value, :ref_no, :item, :anonymous, :in_honor_of, :designation, :notes, :receipt_sent, :volunteer_id, :organization_id, :donation_type_id, :_destroy],
                                      waivers_attributes: [:id, :guardian_id, :adult, :birthdate, :date_signed, :waiver_text, :e_sign, :_destroy])
  end
  def volunteer_search_params
    search_params = params.permit(:name, :city, :workday_since, interest_ids: [], volunteer_category_ids: [])
    search_params.delete_if {|k,v| v.blank?}
    search_params
  end

  def donations_allowed
    redirect_to(root_url) unless current_user.donations_allowed
  end

  def child_form_setup
    @parent = @volunteer.nil? ? Volunteer.find(params[:id]) : @volunteer
    @no_delete = true
    @allow_stay = true
    @custom_submit = "Save & Search"
    @custom_submit_name = "save_and_search"
  end

  def edit_setup
    @volunteer = @volunteer.nil? ? Volunteer.find(params[:id]) : @volunteer
    @num_workdays = WorkdayVolunteer.where(volunteer_id: @volunteer.id)
    @employer = @volunteer.employer_id.blank? ? nil : Organization.find(@volunteer.employer_id)
    @church = @volunteer.church_id.blank? ? nil : Organization.find(@volunteer.church_id)
    @allow_stay = true
    @donation_year = get_donation_summary("volunteer", @volunteer.id)[0].first
    session[:volunteer_id] = @volunteer.id
    session[:child_entry] = nil
  end

end
