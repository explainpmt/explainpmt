module StoriesHelper
  def link_to_new_story
    link_to_remote('Create Story Card', :url => new_project_story_path(@project), :method => :get)
  end
  
  def link_to_story_with_sc(story)
    link_to("SC#{story.scid}", project_story_path(@project, story)) + '(' + truncate(story.title, 30) + ')'
  end
  
  def link_to_story(story)
    link_to(story.title, project_story_path(@project, story))
  end

  def link_to_edit_story(story, options={})
    link_to_remote(options[:value] || story.title, :url => edit_project_story_path(@project, story), :method => :get)
  end
  
  def link_to_new_task(story)
    link_to_remote("Add Task", :url => new_project_story_task_path(@project, story), :method => :get)
  end
  
  def link_to_edit_task(task, options={})
    link_to_remote(options[:value] || task.name, :url => edit_project_story_task_path(@project, task.story, task), :method => :get)
  end

  def link_to_delete_task(task, options={})
    link_to_remote "Delete", :url => project_story_task_path(@project, task.story, task), :method => :delete, :confirm => "Are you sure you want to delete?"
  end
  
  def link_to_task(task, options={})
    link_to_remote(options[:value] || task.name, :url => project_story_task_path(@project, task.story, task), :method => :get)
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
  
  def story_select_list_for(stories)
    options = ""
    stories.each do |i|
      options << "<option value='#{i.id}'>SC#{i.scid}  (#{truncate(i.title,30)})</option>"
    end
    options
  end
end
