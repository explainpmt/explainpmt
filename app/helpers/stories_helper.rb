module StoriesHelper
  def link_to_new_task(story)
    link_to_remote("Add Task", :url => new_project_story_task_path(@project, story), :method => :get)
  end

  def link_to_take_task_ownership(task)
    link_to_remote('take', :url => take_ownership_project_story_task_path(@project, task.story, task), :method => :put)
  end

  def link_to_release_task_ownership(task)
    link_to_remote('release', :url => release_ownership_project_story_task_path(@project, task.story, task), :method => :put)
  end

  def link_to_assign_task_ownership(task)
    link_to_remote('assign', :url => assign_ownership_project_story_task_path(@project, task.story, task), :method => :get)
  end

  def link_to_new_acceptance_for(story)
     link_to_remote('Add Acceptance', :url => new_project_story_acceptancetest_path(@project, story), :method => :get)
  end
  
  def link_to_audit(story)
    link_to_remote('View History', :url => audit_project_story_path(@project, story), :method => :get)
  end
end
