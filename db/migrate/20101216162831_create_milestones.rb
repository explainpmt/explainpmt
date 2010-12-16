class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.integer :project_id, :integer
      t.date    :date, :date
      t.string  :name, :string
      t.text    :description, :text
      t.timestamps
    end
    
    add_index :milestones,  :project_id
  end

  def self.down
    drop_table :milestones
  end
end
