include ApplicationHelper

class PendingVolunteerMailer < ApplicationMailer

  def notification_email(pending_volunteer)
    mail_to = Utilities::Utilities.system_setting(:pending_volunteer_notify_email)
    if !mail_to.blank?
      @pending_volunteer = pending_volunteer
      delivery_options = { user_name: Utilities::Utilities.system_setting(:email_account),
                         password: Utilities::Utilities.system_setting(:email_password),
                         address: Utilities::Utilities.system_setting(:smtp_server),
                         port: Utilities::Utilities.system_setting(:smtp_port),
                         authentication: :plain,
                         enable_starttls_auto: Utilities::Utilities.system_setting(:smtp_starttls),
                         ssl: Utilities::Utilities.system_setting(:smtp_ssl),
                         tls: Utilities::Utilities.system_setting(:smtp_tls)}
      mail(to: mail_to,
           from: "no_reply@#{host_domain}",
           subject: "New Pending Volunteer",
           delivery_method_options: delivery_options)
    end
  end
end
