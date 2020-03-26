include ApplicationHelper

class SettingsController < ApplicationController
  before_action { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:edit, :update]

  def edit
    @object = Setting.find(1)
    @no_delete = true
    render 'edit'
  end

  def update
    @object = Setting.find(1)
    if @object.update_attributes(setting_params)
      flash[:success] = "Settings saved"
      if !params[:to_waivers].blank?
        redirect_to waiver_texts_path
      else
        WillPaginate.per_page = Utilities::Utilities.system_setting(:records_per_page)  # This one needs to update now
        redirect_to root_path
      end
    else
      @no_delete = true
      render 'edit'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def setting_params
    params.require(:setting).permit(:site_title, :site_url, :org_title, :org_short_title, :org_site, :old_system_site, :old_system_name, :no_pagination, :records_per_page, :min_password_length, :adult_age, :waiver_valid_days, :waivers_at_checkin, :allow_waiver_skip,
                                    :pending_volunteer_notify_email, :email_account, :email_password, :smtp_server, :smtp_port, :smpt_starttls, :smtp_ssl, :smtp_tls)
  end


end
