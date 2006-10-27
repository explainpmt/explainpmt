class AddMilestonesTable < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.column :name, :string
      t.column :date, :date
      t.column :project_id, :integer
    end
  end

  def self.down
    drop_table :milestones
  end
end
