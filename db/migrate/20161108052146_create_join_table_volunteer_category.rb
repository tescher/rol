class CreateJoinTableVolunteerCategory < ActiveRecord::Migration
  def change
    create_join_table :volunteers, :volunteer_categories do |t|
      # t.index [:volunteer_id, :volunteer_category_id]
      # t.index [:volunteer_category_id, :volunteer_id]
    end
  end
end
