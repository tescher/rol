class AddMoreSmtPtoSettings < ActiveRecord::Migration
  def change
    add_column :settings, :smtp_ssl, :boolean, default: :true
    add_column :settings, :smtp_tls, :boolean, default: :true
  end
end
