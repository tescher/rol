include WorkdaysHelper

class VolunteersController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :edit, :update, :destroy, :search]
  before_action :admin_user,     only: :destroy


  def search
    if params[:dialog] == "true"
      render partial: "dialog_search_form"
    end
  end

  # GET /volunteers
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
      @volunteers = Volunteer.select("DISTINCT(volunteers.id), volunteers.*").where(where_clause).order(:last_name, :first_name).paginate(page: params[:page], per_page: per_page)
    else

      interest_ids = []
      volunteer_search_params.each do |index|
        if ["last_name", "city"].include?(index[0])
          if index[1].strip.length > 0
            where_clause = where_clause.length > 0 ? where_clause + " AND " : where_clause
            where_clause += "(soundex(#{index[0]}) = soundex('#{index[1]}') OR (LOWER(#{index[0]}) LIKE '#{index[1].downcase}%'))"
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
    end

  end

  # GET /volunteers/1/edit
  def edit
    @volunteer = Volunteer.find(params[:id])
    @num_workdays = WorkdayVolunteer.where(volunteer_id: @volunteer.id)
  end

  # POST /volunteers
  # POST /volunteers.json
  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save
      if params[:volunteer][:dialog] == "true"
        @workday = session[:workday_id]
        render partial: "dialog_add_workday_volunteer_fields"
      else
        flash[:success] = "Volunteer created"
        redirect_to search_volunteers_path
      end
    else
      if params[:volunteer][:dialog] == "true"
        # flash[:danger] = "Could not create volunteer. Make sure fields are filled correctly"
        render partial: "dialog_form"
      else
        render :new
      end
    end
  end

  # PATCH/PUT /volunteers/1
  # PATCH/PUT /volunteers/1.json
  def update
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.update_attributes(volunteer_params)
      flash[:success] = "Volunteer updated"
      redirect_to search_volunteers_path
    else
      render :edit
    end
  end

  # DELETE /volunteers/1
  # DELETE /volunteers/1.json
  def destroy
    Volunteer.find(params[:id]).destroy
    flash[:success] = "Volunteer deleted"
    redirect_to search_volunteers_path
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
                                      :notes, :remove_from_mailing_list, interest_ids: [])
  end
  def volunteer_search_params
    params.permit(:last_name, :city, interest_ids: [])
  end


end
