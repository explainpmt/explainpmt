module StoriesHelper
  def link_to_new_task(story)
    link_to_remote("Add Task", :url => new_project_story_task_path(@project, story), :method => :get)
  end
  
  def link_to_new_acceptance_for(story)
     link_to_remote('Add Acceptance', :url => new_project_story_acceptancetest_path(@project, story), :method => :get)
  end
  
  def link_to_audit(story)
    link_to_remote('View History', :url => audit_project_story_path(@project, story), :method => :get)
  end
end
