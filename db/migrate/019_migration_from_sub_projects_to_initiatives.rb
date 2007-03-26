class MigrationFromSubProjectsToInitiatives < ActiveRecord::Migration
  def self.up
    subProjects = SubProject.find(:all)
    subProjects.each do |sub|
      initiative = Initiative.new
      initiative.id = sub.id
      initiative.project_id = sub.project_id
      initiative.name = sub.name
      initiative.start_date = sub.created_at
      initiative.end_date = sub.updated_at
      initiative.save
    end
    SubProject.delete_all
    drop_table :sub_projects
    execute 'UPDATE stories set initiative_id = sub_project_id'
    remove_column "stories", "sub_project_id"
  end

  def self.down
      add_column "stories", "sub_project_id", :integer
      execute 'UPDATE stories set sub_project_id = initiative_id' 
      create_table :sub_projects do |t|
        t.column "project_id", :integer
        t.column "name", :string
        t.column "created_at", :datetime
        t.column "updated_at", :datetime
      end
      initiatives = Initiative.find(:all)
      initiatives.each do |init|
        subproj = SubProject.new
        subproj.id = init.id
        subproj.project_id = init.project_id
        subproj.name = init.name
        subproj.created_at = init.start_date
        subproj.updated_at = init.end_date
        subproj.save
      end
      Initiative.delete_all
  end
end
