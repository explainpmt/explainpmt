class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.integer :scid
      t.integer :project_id
      t.integer :iteration_id
      t.integer :user_id
      t.string  :title
      t.integer :points
      t.integer :status
      t.integer :value
      t.integer :risk
      t.text    :description
      t.integer :position
      t.string  :customer
      t.integer :initiative_id
      t.integer :creator_id
      t.integer :updater_id
      t.integer :release_id
      t.timestamps
    end
    
    add_index :stories, [:project_id, :position]
    add_index :stories, :iteration_id
    add_index :stories, :user_id
    add_index :stories, :initiative_id
    add_index :stories, :release_id
  end

  def self.down
    drop_table :stories
  end
end
