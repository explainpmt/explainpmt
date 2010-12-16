class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.string  :name
      t.date    :date
      t.integer :project_id
      t.text    :description
      t.timestamps
    end
    
    add_index :releases,  :project_id
  end

  def self.down
    drop_table :releases
  end
end
