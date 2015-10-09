include WorkdaysHelper
include DonationsHelper
include ApplicationHelper

class VolunteersController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search, :address_check, :donations]
  before_action :admin_user,     only: [:destroy, :import, :import_form]
  before_action :donations_allowed, only: [:donations]


  def search
    if params[:dialog] == "true"
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
      where_clause = "remove_from_mailing_list = 'false'"
    else
      if params[:dialog] == "true"
        per_page = 1000000
      else
        per_page = 30
      end
      where_clause = ""
    end
    if params[:show_all]
      @volunteers = Volunteer.select("DISTINCT(volunteers.id), volunteers.*").where(where_clause).order(:last_name, :first_name).paginate(page: params[:page], per_page: per_page)
    else
      if (volunteer_search_params.count < 1)
        @volunteers = Volunteer.none
      else
        interest_ids = []
        volunteer_search_params.each do |index|
          if ["last_name", "city"].include?(index[0])
            if index[1].strip.length > 0
              where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
              where_clause += "(soundex(#{index[0]}) = soundex(#{Volunteer.sanitize(index[1])}) OR (LOWER(#{index[0]}) LIKE #{Volunteer.sanitize(index[1].downcase+ "%")}))"
            end
          end
          if index[0] == "interest_ids"
            interest_ids = index[1]
          end
        end

        if interest_ids.count > 0
          @volunteers = Volunteer.select("DISTINCT(volunteers.id), volunteers.*").joins(:volunteer_interests).where(volunteer_interests: {interest_id: interest_ids}).where(where_clause).order(:last_name, :first_name).paginate(page: params[:page], per_page: per_page)
        else
          @volunteers = Volunteer.select("DISTINCT(volunteers.id), volunteers.*").where(where_clause).order(:last_name, :first_name).paginate(page: params[:page], per_page: per_page)
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

    respond_to do |format|
      format.html {
        if params[:dialog] == "true"
          render partial: "dialog_index"
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
      render partial: "dialog_form"
    else
      @allow_stay = true
    end

  end

  # GET /volunteers/1/edit
  def edit
    @volunteer = Volunteer.find(params[:id])
    @num_workdays = WorkdayVolunteer.where(volunteer_id: @volunteer.id)
    @allow_stay = true
    @donation_year = get_donation_summary("volunteer", @volunteer.id)[0].first
  end

  # POST /volunteers
  # POST /volunteers.json
  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save    # Save successful
      if params[:volunteer][:dialog] == "true"
        @workday = session[:workday_id]
        render partial: "dialog_add_workday_volunteer_fields"
      else
        flash[:success] = "Volunteer created"
        if !params[:to_donations].blank?
          redirect_to donations_volunteer_path(@volunteer)
        else
          if params[:stay].blank?
            redirect_to search_volunteers_path
          else
            redirect_to edit_volunteer_path(@volunteer)
          end
        end
      end
    else                 # Save not successful
      if params[:volunteer][:dialog] == "true"
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
    if volunteer_params[:first_name].nil?     # Coming from donations
      if @volunteer.update_attributes(volunteer_params)
        flash[:success] = "Donations updated"
        if params[:stay].blank?
          redirect_to edit_volunteer_path(@volunteer)
        else
          redirect_to donations_volunteer_path(@volunteer)
        end
      else
        @donator = @volunteer
        @allow_stay = true
        @no_delete = true
        render "shared/donations_form"
      end
    else                                       # Coming from regular edit
      if @volunteer.update_attributes(volunteer_params)
        flash[:success] = "Volunteer updated"
        if !params[:to_donations].blank?
          redirect_to donations_volunteer_path(@volunteer)
        else
          if params[:stay].blank?
            redirect_to search_volunteers_path
          else
            redirect_to edit_volunteer_path(@volunteer)
          end
        end
      else
        @allow_stay = true
        @num_workdays = WorkdayVolunteer.where(volunteer_id: @volunteer.id)
        @donation_year = get_donation_summary("volunteer", @volunteer.id)[0].first
        render :edit
      end
    end
  end

  # DELETE /volunteers/1
  # DELETE /volunteers/1.json
  def destroy
    Volunteer.find(params[:id]).destroy
    flash[:success] = "Volunteer deleted"
    redirect_to search_volunteers_path
  end

  # GET /volunteer/1/donations
  def donations
    @donator = Volunteer.find(params[:id])
    @no_delete = true
    @allow_stay = true
    render "shared/donations_form"
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
                if !fatal
                  @volunteer = Volunteer.new
                  if interests.count > 0
                    @volunteer.interests = interests
                  end
                  record_data.each do |key, value|
                    if key != "notes"
                      if !value.blank?
                        begin
                          @volunteer[key] = (key == "waiver_date") ? Date.strptime(value, "%m/%d/%Y") : value
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

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :middle_name, :email, :occupation,
                                      :address, :city, :state, :zip, :home_phone, :work_phone, :mobile_phone,
                                      :notes, :remove_from_mailing_list, :waiver_date, :background_check_date, interest_ids: [], donations_attributes: [:id, :date_received, :value, :ref_no, :item, :anonymous, :in_honor_of, :designation, :notes, :receipt_sent, :volunteer_id, :organization_id, :donation_type_id, :_destroy])
  end
  def volunteer_search_params
    search_params = params.permit(:last_name, :city, interest_ids: [])
    search_params.delete_if {|k,v| v.blank?}
    search_params
  end
  def donations_allowed
    redirect_to(root_url) unless current_user.donations_allowed
  end




end
