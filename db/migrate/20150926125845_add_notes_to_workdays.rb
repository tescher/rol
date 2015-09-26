class AddNotesToWorkdays < ActiveRecord::Migration
  def change
    add_column :workdays, :notes, :string
  end
end
