class CreateAcceptanceTests < ActiveRecord::Migration
  def self.up
    create_table :acceptance_tests do |t|
      t.string  :name, :string
      t.boolean :automated, :default => 0
      t.integer :project_id
      t.text    :pre_condition
      t.text    :post_condition
      t.text    :expected_result
      t.text    :description
      t.integer :story_id
      t.boolean :pass, :default => 0
      t.timestamps
    end
    
    add_index :acceptance_tests,  :project_id
    add_index :acceptance_tests,  :story_id
  end

  def self.down
    drop_table :acceptance_tests
  end
end
