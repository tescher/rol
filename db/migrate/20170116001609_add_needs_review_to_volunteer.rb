class AddNeedsReviewToVolunteer < ActiveRecord::Migration
  def change
    add_column :volunteers, :needs_review, :boolean, :default => false
  end
end
