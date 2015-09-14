class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.integer :organization_type_id
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :phone
      t.string :notes
      t.string :contact_name
      t.string :old_id
      t.boolean :remove_from_mailing_list, default: false, null: false


      t.timestamps null: false

    end
  end
end
