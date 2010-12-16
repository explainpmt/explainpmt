class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string  :name
      t.text    :description
      t.boolean :complete,  :default => 0
      t.integer :story_id
      t.integer :user_id
      t.timestamps
    end
    
    add_index :tasks, :story_id
    add_index :tasks, :user_id
  end

  def self.down
    drop_table :tasks
  end
end
