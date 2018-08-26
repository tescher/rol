class AddWaiverTextToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :adult_waiver_text, :string
    add_column :settings, :minor_waiver_text, :string
  end
end
