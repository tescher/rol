include ApplicationHelper

class SettingsController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_admin_user, only: [:edit, :update]

  def edit
    @object = Setting.find(1)
    @no_delete = true
    render 'edit'
  end

  def update
    @object = Setting.find(1)
    if @object.update_attributes(setting_params)
      flash[:success] = "Settings updated"
      WillPaginate.per_page = Utilities::Utilities.system_setting(:records_per_page)  # This one needs to update now
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def setting_params
    params.require(:setting).permit(:site_title, :org_title, :org_short_title, :org_site, :old_system_site, :old_system_name, :no_pagination, :records_per_page, :min_password_length)
  end


end
