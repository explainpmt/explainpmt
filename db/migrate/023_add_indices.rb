class AddIndices < ActiveRecord::Migration

  def self.up
    add_index :acceptancetests, :project_id
    add_index :acceptancetests, :story_id
    add_index :audits, [:object, :audited_object_id]
    add_index :initiatives, :project_id
    add_index :iterations, :project_id
    add_index :iterations, :start_date
    add_index :milestones, :project_id
    add_index :project_memberships, :project_id
    add_index :project_memberships, :user_id
    add_index :releases, :project_id
    add_index :stories, [:project_id, :position]
    add_index :stories, :iteration_id
    add_index :stories, :user_id
    add_index :stories, :initiative_id
    add_index :tasks, [:story_id, :user_id]
    add_index :tasks, :user_id
  end

  def self.down
    remove_index :acceptancetests, :project_id
    remove_index :acceptancetests, :story_id
    remove_index :audits, [:object, :audited_object_id]
    remove_index :initiatives, :project_id
    remove_index :iterations, :project_id
    remove_index :iterations, :start_date
    remove_index :milestones, :project_id
    remove_index :project_memberships, :project_id
    remove_index :project_memberships, :user_id
    remove_index :releases, :project_id
    remove_index :stories, [:project_id, :position]
    remove_index :stories, :iteration_id
    remove_index :stories, :user_id
    remove_index :stories, :initiative_id
    remove_index :tasks, [:story_id, :user_id]
    remove_index :tasks, :user_id
  end

end
