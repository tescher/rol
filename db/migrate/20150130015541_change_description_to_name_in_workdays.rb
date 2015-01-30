class ChangeDescriptionToNameInWorkdays < ActiveRecord::Migration
  def change
    add_column :workdays, :name, :string
    remove_column :workdays, :description, :string
  end
end
