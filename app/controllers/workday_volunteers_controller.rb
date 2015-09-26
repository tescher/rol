include SessionsHelper

class WorkdayVolunteersController < ApplicationController
  before_action :admin_user,     only: [:import, :import_form]

  # GET /workday_volunteers/import
  def import_form
    render :import
  end

  # PUT /workday_volunteers/import
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
            record_data["workday_old_id"] = record.xpath("workday_old_id").inner_text
            record_data["start_time"] = record.xpath("start_time").inner_text
            record_data["end_time"] = record.xpath("end_time").inner_text
            record_data["hours"] = record.xpath("hours").inner_text
            record_data["notes"] = record.xpath("notes").inner_text
            message_data = "Sequence: #{sequence}, Old ID: #{record_data["old_id"]}, Workday ID: #{record_data["workday_old_id"]}, Volunter ID: #{record_data["volunteer_old_id"]}"
            if record_data["old_id"].blank?
              fatal = true
              @messages << "Missing id from old system. #{message_data}"
            else
              if record_data["volunteer_old_id"].blank?
                fatal = true
                @messages << "Missing volunteer id from old system. #{message_data}"
              else
                if record_data["workday_old_id"].blank?
                  fatal = true
                  @messages << "Missing workday id from old system. #{message_data}"
                else

                  if !(WorkdayVolunteer.find_by_old_id(record_data["old_id"]).nil?)
                    fatal = true
                    @messages << "Imported previously. #{message_data}"
                  else
                    @volunteer = Volunteer.find_by_old_id(record_data["volunteer_old_id"])
                    if (@volunteer.nil?)
                      fatal = true
                      @messages << "Volunteer not found. #{message_data}"
                    else
                      @workday = Workday.find_by_old_id(record_data["workday_old_id"])
                      if (@workday.nil?)
                        fatal = true
                        @messages << "Workday not found. #{message_data}"
                      else
                        @workday_volunteer = WorkdayVolunteer.new

                        record_data.each do |key, value|
                          if !value.blank?
                            if key == "volunteer_old_id"
                              @workday_volunteer["volunteer_id"] = @volunteer.id
                            else
                              if key == "workday_old_id"
                                @workday_volunteer["workday_id"] = @workday.id
                              else
                                @workday_volunteer[key] = ((key == "start_time") || (key == "end_time")) ? (Date.strptime(@workday.workdate, "%m/%d/%Y") + Date.strptime(value, "%H:%M:%S")) :value
                              end
                            end
                          end
                        end
                        if !@workday_volunteer.valid?
                          @messages << "Validation errors. #{message_data}"
                          @workday_volunteer.errors.full_messages.each do |message|
                            @messages << " -- #{message}"
                          end
                          fatal = true
                        end
                      end
                    end
                  end
                end
              end
            end
            if !fatal
              @records_validated += 1
              if !validate_only
                begin
                  @workday_volunteer.save
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

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

end
