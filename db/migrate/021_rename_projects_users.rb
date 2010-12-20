class RenameProjectsUsers < ActiveRecord::Migration
  def self.up
   rename_table :projects_users, :project_memberships
  end

  def self.down
    rename_table :project_memberships, :projects_users
  end
end
