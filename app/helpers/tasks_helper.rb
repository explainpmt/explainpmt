module TasksHelper
  def link_to_new_task(story)
    link_to "Add Task", new_project_story_task_path(current_project, story), :class => "form popup"
  end

  def link_to_edit_task(task, options={})
    story = task.story
    link_to (options[:text] || task.name), edit_project_story_task_path(story.project, story, task), :class => "form popup edit tip", :title => "edit"
  end

  def link_to_delete_task(task)
    link_to "Delete", project_story_task_path(current_project, task.story, task), :class => "delete popup tip", "data-message" => "Are you sure you want to delete?", :title => "delete"
  end

  def link_to_task(task, options={})
    link_to (options[:text] || task.name), :url => project_story_task_path(current_project, task.story, task)
  end

  def link_to_take_task_ownership(task)
    link_to 'take', take_ownership_project_story_task_path(current_project, task.story, task), :method => :put
  end

  def link_to_assign_task_ownership(task)
    link_to 'assign', assign_ownership_project_story_task_path(current_project, task.story, task), :class => "form popup"
  end

  def link_to_release_task_ownership(task)
    link_to 'release', release_ownership_project_story_task_path(current_project, task.story, task), :method => :put
  end
end
