class ChangePrioritycolumnToValueColumnOnStoriesTable < ActiveRecord::Migration
  def self.up
    rename_column :stories, :priority, :value
  end

  def self.down
    rename_column :stories, :value, :priority
  end
end
