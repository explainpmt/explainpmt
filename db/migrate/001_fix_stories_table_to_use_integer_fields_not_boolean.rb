class FixStoriesTableToUseIntegerFieldsNotBoolean < ActiveRecord::Migration
  def self.up
    change_column :stories, :status, :integer
    change_column :stories, :risk, :integer
    change_column :stories, :priority, :integer
  end

  def self.down
    change_column :stories, :status, :boolean
    change_column :stories, :risk, :boolean
    change_column :stories, :priority, :boolean
  end
end
