class AddExtensions < ActiveRecord::Migration
  def up
      execute "create extension fuzzystrmatch"
  end
end
