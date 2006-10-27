class AddProjectsTable < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :name, :string
    end

    create_table :projects_users, :id => false do |t|
      t.column :project_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :projects_users
    drop_table :projects
  end
end
