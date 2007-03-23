class CreateReleasesTable < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.column :date, :date
      t.column :project_id, :integer
      t.column :name, :string
      t.column :description, :text
      t.column :created_at, :date
      t.column :updated_at, :date
    end
  end

  def self.down
    drop_table :releases
  end
end
