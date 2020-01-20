include ApplicationHelper
include DonationsHelper

class ContactsController < ApplicationController
  before_action :set_contact, only: [:edit, :update, :destroy]
  before_action :logged_in_user, only: [:create, :new, :edit, :update, :destroy]
  before_action :admin_user,     only: [:destroy]

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
    if @contact.user_id.nil?
      if !@current_user.admin? && !@current_user.can_edit_unowned_contacts?
        flash[:error] = "Can't edit contact for another user"
        redirect_to root_url
        return
      end
    else if !@current_user.admin? && @current_user.id != @contact.user_id
        flash[:error] = "Can't edit contact for another user"
        redirect_to root_url
        return
      end
    end
    volunteer_info_setup
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    @volunteer = Volunteer.find(@contact.volunteer_id)
    @contact.last_edit_user_id = @current_user.id
    if @contact.user_id.nil?
      @contact.user_id = @current_user.id
    else if (!@current_user.admin? && (@contact.user_id != @current_user.id))
           # Someone trying to create a contact owned by someone else
           flash[:error] = "Cannot create contact for another user"
           # puts "Redirecting"
           redirect_to root_url
           return
         end
    end

    if @contact.save
      @volunteer.notes = params[:permanent_notes]
      @volunteer.save
      # puts "Contact saved"
      render html: '<body onload="window.close()"></body>'.html_safe
    else
      # puts "Contact not saved"
      # puts flash[:error]
      volunteer_info_setup
      render :new
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    @contact = Contact.find(params[:id])
    @volunteer = Volunteer.find(@contact.volunteer_id)
    @contact.last_edit_user_id = @current_user.id
    if @contact.update(contact_params)
      @volunteer.notes = params[:permanent_notes]
      @volunteer.save
      render html: '<body onload="window.close()"></body>'.html_safe
    else
      volunteer_info_setup
      render :edit
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    render  html: '<body onload="window.close()"></body>'.html_safe
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
    contact_params = params.require(:contact).permit(:contact_date, :contact_time, :contact_method_id, :volunteer_id, :notes, :user_id)
    # puts contact_params
    contact_date  = contact_params[:contact_date].blank? ? DateTime.now.strftime("%m/%d/%Y") : contact_params[:contact_date]
    contact_time  = contact_params[:contact_time].blank? ? DateTime.now.strftime("%l:%M %p") : contact_params[:contact_time]
    contact_params[:date_time] = DateTime.strptime("#{contact_date} #{contact_time}","%m/%d/%Y %l:%M %p" ) rescue nil
    # puts contact_params
    contact_params.delete("contact_date")
    contact_params.delete("contact_time")
    # puts contact_params
    # puts params
    contact_params
  end

  def volunteer_info_setup
    @num_workdays = WorkdayVolunteer.where(volunteer_id: @volunteer.id)
  end

end
