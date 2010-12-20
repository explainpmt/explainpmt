class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
    t.column :name, :string
    t.column :description, :text
    t.column :complete, :boolean, :default => false
    t.column :story_id, :integer
    t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :tasks
  end
end
