class AddNotifyIfPendingtoUsers < ActiveRecord::Migration
  def change
    add_column :users, :notify_if_pending, :boolean, default: false
  end
end
