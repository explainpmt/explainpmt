class AddPositionToStory < ActiveRecord::Migration
  def self.up
    add_column "stories", "position", :integer
    projects = Project.find(:all)
      projects.each do |project|
        project.stories.each_with_index do |story, i|
          	    story.position = i
        	    story.save
        end
      end
  end

  def self.down
    remove_column "stories", "position"
  end
  
end
