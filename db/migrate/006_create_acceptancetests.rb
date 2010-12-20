class CreateAcceptancetests < ActiveRecord::Migration
  def self.up
    create_table :acceptancetests do |t|
      t.column :name, :string
      t.column :automated, :boolean, :default => false
      t.column :project_id, :integer
      t.column :pre_condition, :string
      t.column :post_condition, :string
      t.column :expected_result, :string
      t.column :description, :string
      t.column :story_id, :integer
      t.column :pass, :boolean, :default => false
    end
  end

  def self.down
    drop_table :acceptancetests
  end
end
