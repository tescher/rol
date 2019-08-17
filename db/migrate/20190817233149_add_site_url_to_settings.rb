class AddSiteUrlToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :site_url, :string
  end
end
