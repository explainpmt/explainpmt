module TasksHelper
  def link_to_new_task(story)
    link_to_remote("Add Task", :url => new_project_story_task_path(@project, story), :method => :get)
  end
  
  def link_to_edit_task(task, options={})
    link_to_remote(options[:value] || task.name, :url => edit_project_story_task_path(@project, task.story, task), :method => :get)
  end

  def link_to_delete_task(task)
    link_to_remote "Delete", :url => project_story_task_path(@project, task.story, task), :method => :delete, :confirm => "Are you sure you want to delete?"
  end
  
  def link_to_task(task, options={})
    link_to_remote(options[:value] || task.name, :url => project_story_task_path(@project, task.story, task), :method => :get)
  end

  def link_to_take_task_ownership(task)
    link_to_remote('take', :url => take_ownership_project_story_task_path(@project, task.story, task), :method => :put)
  end

  def link_to_assign_task_ownership(task)
    link_to_remote('assign', :url => assign_ownership_project_story_task_path(@project, task.story, task), :method => :get)
  end

  def link_to_release_task_ownership(task)
    link_to_remote('release', :url => release_ownership_project_story_task_path(@project, task.story, task), :method => :put)
  end
end
