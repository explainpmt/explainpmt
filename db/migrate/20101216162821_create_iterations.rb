class CreateIterations < ActiveRecord::Migration
  def self.up
    create_table :iterations do |t|
      t.string  :name
      t.integer :project_id
      t.date    :start_date
      t.integer :length
      t.integer :budget
      
      t.timestamps
    end
    
    add_index :iterations,  [:project_id, :name], :unique => true
    add_index :iterations,  :start_date
  end

  def self.down
    drop_table :iterations
  end
end
