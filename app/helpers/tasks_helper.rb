module TasksHelper
  def link_to_new_task(story)
    link_to "Add Task", new_project_story_task_path(@project, story)
  end

  def link_to_edit_task(task, options={})
    story = task.story
    link_to (options[:text] || task.name), edit_project_story_task_path(story.project, story, task)
  end

  def option_to_edit_task(task)
    story = task.story
    create_action_option("Edit", edit_project_story_task_path(story.project, story, task))
  end

  def option_to_delete_task(task)
    create_action_option("Delete", project_story_task_path(@project, task.story, task), :method => :delete, :confirm => "Are you sure you want to delete?")
  end

  def link_to_task(task, options={})
    link_to (options[:text] || task.name), :url => project_story_task_path(@project, task.story, task)
  end

  def link_to_take_task_ownership(task)
    link_to 'take', take_ownership_project_story_task_path(@project, task.story, task), :method => :put
  end

  def link_to_assign_task_ownership(task)
    link_to 'assign', assign_ownership_project_story_task_path(@project, task.story, task)
  end

  def link_to_release_task_ownership(task)
    link_to 'release', release_ownership_project_story_task_path(@project, task.story, task), :method => :put
  end
end
