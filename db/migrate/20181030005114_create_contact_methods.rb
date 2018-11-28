class CreateContactMethods < ActiveRecord::Migration
  def change
    create_table :contact_methods do |t|
      t.string :name
      t.boolean :inactive

      t.timestamps null: false
    end
  end
end
