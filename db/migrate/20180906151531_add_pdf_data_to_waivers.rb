class AddPdfDataToWaivers < ActiveRecord::Migration
  def change
    add_column :waivers, :filename, :string
    add_column :waivers, :data, :binary
  end
end
