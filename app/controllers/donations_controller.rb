include SessionsHelper
include DonationsHelper
include ApplicationHelper

class DonationsController < ApplicationController
  before_action :logged_in_user, only: [:report]
  before_action :admin_user,     only: [:import, :import_form]
  before_action :donations_allowed, only: [:donation_summary]

  def report
    if !params[:report_type].nil?    # Will render report form on initial get

      if params[:request_format] == "xls"
        per_page = 1000000   #Hopefully all of them!
        request.format = :xls
      else if params[:request_format] == "csv"
             request.format = :csv
           else
             per_page = 30
           end
      end

      @report_type = params[:report_type].to_i
      @report_object = params[:donation_report_object]

      where_clause = ""

      if !params[:from_date].empty?
        where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
        where_clause += "donations.date_received >= '#{Date.strptime(params[:from_date], "%m/%d/%Y").to_s}'"
      end
      if !params[:to_date].empty?
        where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
        where_clause += "donations.date_received <= '#{Date.strptime(params[:to_date], "%m/%d/%Y").to_s}'"
      end

      if params[:needing_receipts]
        where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
        where_clause += "donations.receipt_sent IS FALSE"
      end

      if !params[:donation_type_ids].nil? && params[:donation_type_ids].count > 0
        where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
        where_clause += "donation_types.id IN (" + params[:donation_type_ids].join(",") + ")"
      end

      where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
      if @report_type == 1
        where_clause += "donation_types.non_monetary IS FALSE"
      else
        where_clause += "donation_types.non_monetary IS TRUE"
      end

      if @report_object == "organizations"
        organization_where = where_clause
        organization_type_ids = params[:organization_type_ids].nil? ? [] : params[:organization_type_ids]
        organization_where = organization_where.length > 0 ? organization_where + " AND " : organization_where
        if organization_type_ids.count > 0
          organization_where += "organizations.organization_type_id IN (" + organization_type_ids.join(",") + ")"
        else
          organization_where += "organizations.organization_type_id IS NOT NULL"
        end

        if !params[:city].empty?
          organization_where_city = ""
          params[:city].split(",").each do |p|
            organization_where_city = organization_where_city.length > 0 ? organization_where_city + " OR " : organization_where_city
            organization_where_city += "LOWER(organizations.city) LIKE #{Organization.sanitize(p.strip.downcase + "%")}"
          end
          if organization_where_city.length > 0
            organization_where = organization_where.length > 0 ? organization_where + " AND " : organization_where
            organization_where += "(" + organization_where_city + ")"
          end
        end
        if !params[:zip].empty?
          organization_where_zip = ""
          params[:zip].split(",").each do |p|
            organization_where_zip = organization_where_zip.length > 0 ? organization_where_zip + " OR " : organization_where_zip
            organization_where_zip += "LOWER(organizations.zip) LIKE #{Organization.sanitize(p.strip.downcase + "%")}"
          end
          if organization_where_zip.length > 0
            organization_where = organization_where.length > 0 ? organization_where + " AND " : organization_where
            organization_where += "(" + organization_where_zip + ")"
          end

        end

        @donations = Donation.joins(:organization, :donation_type).where(organization_where).order("organizations.name, donations.date_received")
      end

      if @report_object == "volunteers"
        volunteer_where = where_clause
        if !params[:city].empty?
          volunteer_where_city = ""
          params[:city].split(",").each do |p|
            volunteer_where_city = volunteer_where_city.length > 0 ? volunteer_where_city + " OR " : volunteer_where_city
            volunteer_where_city += "LOWER(volunteers.city) LIKE #{Volunteer.sanitize(p.strip.downcase + "%")}"
          end
          if volunteer_where_city.length > 0
            volunteer_where = volunteer_where.length > 0 ? volunteer_where + " AND " : volunteer_where
            volunteer_where += "(" + volunteer_where_city + ")"
          end
        end
        if !params[:zip].empty?
          volunteer_where_zip = ""
          params[:zip].split(",").each do |p|
            volunteer_where_zip = volunteer_where_zip.length > 0 ? volunteer_where_zip + " OR " : volunteer_where_zip
            volunteer_where_zip += "LOWER(volunteers.zip) LIKE #{Volunteer.sanitize(p.strip.downcase + "%")}"
          end
          if volunteer_where_zip.length > 0
            volunteer_where = volunteer_where.length > 0 ? volunteer_where + " AND " : volunteer_where
            volunteer_where += "(" + volunteer_where_zip + ")"
          end
        end
        @donations = Donation.joins(:volunteer, :donation_type).where("donations.volunteer_id IS NOT NULL").where(volunteer_where).order("volunteers.last_name, volunteers.first_name, donations.date_received")
      end

      respond_to do |format|
        format.html {
          render "report_donations.html"
        }
        format.xls {
          response.headers['Content-Disposition'] = 'attachment; filename="report.xls"'
          render "report_donations.xls"
        }
        format.csv {
          headers['Content-Disposition'] = "attachment; filename=\"donations\""
          headers['Content-Type'] ||= 'text/csv'
          send_data @donations.to_csv(@report_object) }


      end
    end

  end

  # GET /donations/import
  def import_form
    render :import
  end

  # PUT /donations/import
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
            record_data["volunteer_old_id"] = record.xpath("volunteer_old_id").inner_text
            record_data["organization_old_id"] = record.xpath("organization_old_id").inner_text
            record_data["date_received"] = record.xpath("date_received").inner_text
            record_data["value"] = record.xpath("value").inner_text
            record_data["ref_no"] = record.xpath("ref_no").inner_text
            record_data["item"] = record.xpath("item").inner_text
            record_data["anonymous"] = record.xpath("anonymous").inner_text
            record_data["in_honor_of"] = record.xpath("in_honor_of").inner_text
            record_data["designation"] = record.xpath("designation").inner_text
            record_data["notes"] = record.xpath("notes").inner_text
            record_data["receipt_sent"] = record.xpath("receipt_sent").inner_text
            record_data["donation_type"] = record.xpath("donation_type").inner_text
            record_data["organization_type"] = record.xpath("organization_type").inner_text
            message_data = "Sequence: #{sequence}, Old ID: #{record_data["old_id"]}, Organization ID: #{record_data["organization_old_id"]}, Volunteer ID: #{record_data["volunteer_old_id"]}, Donation Type: #{record_data["donation_type"]}"
            @organization = nil
            @volunteer = nil
            @donation_type = nil
            if record_data["old_id"].blank?
              fatal = true
              @messages << "Missing id from old system. #{message_data}"
            else
              if record_data["volunteer_old_id"].blank? && record_data["organization_old_id"].blank?
                fatal = true
                @messages << "Missing volunteer or organization id from old system. #{message_data}"
              else
                if record_data["donation_type"].blank?
                  fatal = true
                  @messages << "Missing donation type from old system. #{message_data}"
                else
                  @donation_type = DonationType.where("name ilike ?", "%#{record_data["donation_type"]}").first
                  if @donation_type.nil?
                    @messages << "Missing #{record_data["donation_type"]} donation type mapping. #{message_data}"
                    fatal = true
                  else
                    if !(Donation.find_by_old_id(record_data["old_id"]).nil?)
                      fatal = true
                      @messages << "Imported previously. #{message_data}"
                    else
                      if !record_data["organization_old_id"].blank?
                        if record_data["organization_type"].blank?
                          fatal = true
                          @messages << "Missing organization type from old system. #{message_data}"
                        else
                          organization_type = OrganizationType.where("name ilike ?", "%#{record_data["organization_type"]}").first
                          if organization_type.nil?
                            @messages << "Missing #{record_data["organization_type"]} organization type mapping. #{message_data}"
                            fatal = true
                          end
                          @organization = Organization.find_by_old_id_and_organization_type_id(record_data["organization_old_id"], organization_type.id)
                          if @organization.nil?
                            @messages << "Organization not found. #{message_data}"
                            fatal = true
                          end
                        end
                      else
                        @volunteer = Volunteer.find_by_old_id(record_data["volunteer_old_id"])
                        if (@volunteer.nil?)
                          fatal = true
                          @messages << "Volunteer not found. #{message_data}"
                        end
                      end
                    end
                  end
                end
              end
            end
            if !fatal
              @donation = Donation.new
              @donation.skip_item_check = true
              record_data.each do |key, value|
                if (!value.blank?) && (key != "notes")
                  if key == "volunteer_old_id"
                    @donation["volunteer_id"] = @volunteer.id
                  else
                    if key == "organization_old_id"
                      @donation["organization_id"] = @organization.id
                    else
                      if key == "donation_type"
                        @donation["donation_type_id"] = @donation_type.id
                      else
                        if key == "organization_type"
                        else
                          begin
                            @donation[key] = (key == "date_received") ? Date.strptime(value, "%m/%d/%Y") :value
                          rescue => ex
                            @messages << "Warning: Invalid " + key + " data (" + value + "), saved in notes field. #{message_data}"
                            @messages << " -- #{ex.message}"
                            record_data["notes"] += ". Invalid " + key + " data found in conversion: " + value
                          end
                        end
                      end
                    end
                  end
                end
              end
              if !record_data["notes"].blank?
                @donation.notes = record_data["notes"]
              end
              if !@donation.valid?
                @messages << "Validation errors. #{message_data}. " + (!@volunteer.nil? ? "Volunteer: #{@volunteer.first_name} #{@volunteer.last_name} ": "") + (!@organization.nil? ? "Organization: #{@organization.name} ": "")
                @donation.errors.full_messages.each do |message|
                  @messages << " -- #{message}"
                end
                fatal = true
              end
              if !fatal
                @records_validated += 1
                if !validate_only
                  begin
                    @donation.save
                    @records_imported += 1
                  rescue => ex
                    @messages << "Save error. #{message_data}"
                    @messages << " -- #{ex.message}"
                  end

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

  def donation_summary
    @objectName = params[:object_name].downcase
    @non_monetary = ActiveRecord::Type::Boolean.new.cast(params[:non_monetary])
    if (@objectName != "volunteer") && (@objectName != "organization")
      render partial: "Invalid parameter"
    else
      @donation_years, @donations_by_year, @year_totals, @donation_grand_total = get_donation_summary(@objectName, params[:id], @non_monetary)
      render partial: "dialog_donation_summary"
    end
  end

  private

  def donations_allowed
    redirect_to(root_url) unless current_user.donations_allowed
  end

end
