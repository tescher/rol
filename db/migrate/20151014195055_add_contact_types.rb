class AddContactTypes < ActiveRecord::Migration
  def change
    create_table :contact_types do |t|
      t.string :name
      t.boolean :inactive, default: false, null: false

      t.timestamps null: false
    end
  end
end
