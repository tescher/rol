class AddAdultAgeToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :adult_age, :integer
  end
end
