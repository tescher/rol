include ApplicationHelper
include DonationsHelper

class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :show, :create, :new, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @volunteer = @volunteer || Volunteer.find(params[:volunteer_id])
    @contact = Contact.new(volunteer_id: @volunteer.id)
    volunteer_info_setup
  end

  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
    @volunteer = Volunteer.find(@contact.volunteer_id)
    volunteer_info_setup
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    @volunteer = Volunteer.find(@contact.volunteer_id)

    if @contact.save
      @volunteer.notes = params[:permanent_notes]
      @volunteer.save
      render :text => '<body onload="window.close()"></body>'
    else
      volunteer_info_setup
      render :new
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    @contact = Contact.find(params[:id])
    @volunteer = Volunteer.find(@contact.volunteer_id)
    if @contact.update(contact_params)
      @volunteer.notes = params[:permanent_notes]
      @volunteer.save
      render :text => '<body onload="window.close()"></body>'
    else
      volunteer_info_setup
      render :edit
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    render :text => '<body onload="window.close()"></body>'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contact_params
    params[:permanent_notes] = params[:contact][:permanent_notes]
    params[:contact].delete("permanent_notes")
    contact_params = params.require(:contact).permit(:contact_date, :contact_time, :contact_method_id, :volunteer_id, :notes)
    puts contact_params
    contact_date  = contact_params[:contact_date].blank? ? DateTime.now.strftime("%m/%d/%Y") : contact_params[:contact_date]
    contact_time  = contact_params[:contact_time].blank? ? DateTime.now.strftime("%l:%M %p") : contact_params[:contact_time]
    contact_params[:date_time] = DateTime.strptime("#{contact_date} #{contact_time}","%m/%d/%Y %l:%M %p" ) rescue nil
    puts contact_params
    contact_params.delete("contact_date")
    contact_params.delete("contact_time")
    puts contact_params
    puts params
    contact_params
  end

  def volunteer_info_setup
    @num_workdays = WorkdayVolunteer.where(volunteer_id: @volunteer.id)
    @donation_year = get_donation_summary("volunteer", @volunteer.id)[0].first
  end

end
