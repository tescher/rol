class AddInactiveToDonationTypes < ActiveRecord::Migration
  def change
    add_column :donation_types, :inactive, :boolean, default: false, null: false
  end
end
