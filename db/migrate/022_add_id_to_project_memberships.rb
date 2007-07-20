class AddIdToProjectMemberships < ActiveRecord::Migration
  class ProjectMemberships < ActiveRecord::Base
  end
  
  def self.up
    memberships = ProjectMemberships.find(:all)
    create_table :project_memberships, :force => true do |t|
      t.column :user_id, :integer
      t.column :project_id, :integer
      end
      memberships.each do |member|
        membership = ProjectMembership.new
        membership.user_id = member.user_id
        membership.project_id = member.project_id
        membership.save!
      end
  end

  def self.down
    remove_column "project_memberships", "id"
  end
end
