class AddPvMailerToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :pending_volunteer_notify_email, :string
    add_column :settings, :email_account, :string
    add_column :settings, :email_password, :string
    add_column :settings, :smtp_server, :string
    add_column :settings, :smtp_port, :string
    add_column :settings, :smtp_starttls, :boolean, default: :true
  end
end
