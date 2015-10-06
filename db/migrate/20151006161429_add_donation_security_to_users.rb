class AddDonationSecurityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :all_donations, :boolean, default: false,  null: false
    add_column :users, :non_monetary_donations, :boolean, default: false, null: false
  end
end
