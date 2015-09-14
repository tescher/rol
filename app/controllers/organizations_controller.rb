include WorkdaysHelper

class OrganizationsController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search, :address_check]
  before_action :admin_user,     only: [:destroy, :import, :import_form]


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

  # GET /organizations
  def index
    if params[:request_format] == "xls"
      per_page = 1000000   #Hopefully all of them!
      request.format = :xls
      where_clause = "remove_from_mailing_list = 'false'"
    else
      per_page = 30
      where_clause = ""
    end
    if params[:show_all]
      @organizations = Organization.select("DISTINCT(organizations.id), organizations.*").where(where_clause).order(:name, :city).paginate(page: params[:page], per_page: per_page)
    else

      interest_ids = []
      organization_search_params.each do |index|
        if ["name", "city"].include?(index[0])
          if index[1].strip.length > 0
            where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
            where_clause += "(soundex(#{index[0]}) = soundex('#{index[1]}') OR (LOWER(#{index[0]}) LIKE '#{index[1].downcase}%'))"
          end
        end
        if index[0] == "interest_ids"
          interest_ids = index[1]
        end
      end


        @organizations = Organization.select("DISTINCT(organizations.id), organizations.*").where(where_clause).order(:name, :city).paginate(page: params[:page], per_page: per_page)

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
        response.headers['Content-Disposition'] = 'attachment; filename="organizations.xls"'
        render "index.xls"
      }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    @organization = Organization.find(params[:id])
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
    @num_workdays = []
    if params[:dialog] == "true"
      render partial: "dialog_form"
    end

  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
     # @num_workdays = WorkdayOrganization.where(organization_id: @organization.id)
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      if params[:organization][:dialog] == "true"
        @workday = session[:workday_id]
        render partial: "dialog_add_workday_organization_fields"
      else
        flash[:success] = "Organization created"
        redirect_to search_organizations_path
      end
    else
      if params[:organization][:dialog] == "true"
        # flash[:danger] = "Could not create organization. Make sure fields are filled correctly"
        render partial: "dialog_form"
      else
        render :new
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(organization_params)
      flash[:success] = "Organization updated"
      redirect_to search_organizations_path
    else
      @num_workdays = []
      render :edit
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    Organization.find(params[:id]).destroy
    flash[:success] = "Organization deleted"
    redirect_to search_organizations_path
  end

  # GET /organizations/import
  def import_form
    render :import
  end

  # PUT /organizations/import
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
              if !(Organization.find_by_old_id(record_data["old_id"]).nil?)
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
                  @organization = Organization.new
                  record_data.each do |key, value|
                    if !value.blank?
                      @organization[key] = (key == "waiver_date") ? Date.strptime(value, "%m/%d/%Y") : value
                    end
                  end
                  if !@organization.valid?
                    @messages << "Validation errors. #{message_data}"
                    @organization.errors.full_messages.each do |message|
                      @messages << " -- #{message}"
                    end
                    fatal = true
                  end
                end
              end
            end
            if !fatal
              @records_validated += 1
              if !validate_only
                begin
                  @organization.save
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
  def organization_params
    params.require(:organization).permit(:name, :email, :contact_name,
                                      :address, :city, :state, :zip, :phone,
                                      :notes, :remove_from_mailing_list, :organization_type_id)
  end
  def organization_search_params
    params.permit(:name, :city, :organization_type_id)
  end


end
