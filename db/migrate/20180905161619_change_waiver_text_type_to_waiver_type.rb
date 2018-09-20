class ChangeWaiverTextTypeToWaiverType < ActiveRecord::Migration
  def change
    rename_column :waiver_texts, :type, :waiver_type
  end
end
