module StoriesHelper
  
  def link_to_new_story
    link_to 'Create Story Card', new_project_story_path(current_project), :class => "form popup"
  end

  def link_to_show_cancelled
    nav_item 'Show Cancelled', cancelled_project_stories_path(current_project)
  end
  
  def link_to_show_all
    nav_item 'Show All', all_project_stories_path(current_project)
  end

  def link_to_new_iteration_story(iteration)
    link_to 'Create Story Card', new_project_iteration_story_path(current_project, iteration), :class => "form popup"
  end

  def link_to_new_stories
    link_to 'Bulk Create', bulk_create_project_stories_path(current_project)
  end

  def link_to_story_with_sc(story)
    link_to("SC#{story.scid}", project_story_path(current_project, story)) + '(' + truncate(story.title, :length => 30) + ')'
  end

  def link_to_story(story, options={})
    link_to(options[:text] || story.title, project_story_path(story.project, story))
  end

  def link_to_assign_story_ownership(story)
    link_to 'assign', assign_ownership_project_story_path(current_project, story)
  end

  def link_to_take_story_ownership(story)
    link_to('take', take_ownership_project_story_path(current_project, story), :method => :put)
  end

  def link_to_release_story_ownership(story)
    link_to('release', release_ownership_project_story_path(current_project, story), :method => :put)
  end

  def link_to_new_acceptance_for(story)
    link_to 'Add Acceptance', new_project_story_acceptance_test_path(current_project, story), :class => "form popup"
  end

  def link_to_export_stories
    link_to 'Export All Stories', export_project_stories_path(current_project)
  end

  def link_to_export_tasks
    link_to 'Export All Tasks', export_tasks_project_stories_path(current_project)
  end

  def story_select_list_for(stories)
    stories.inject(""){|options, story| options << "<option value='#{story.id}'>SC#{story.scid}  (#{truncate(story.title, :length => 30)})</option>"}
  end

  def link_to_audit_story(story)
    link_to "View History", audit_project_story_path(current_project, story)
  end

  def link_to_edit_story(story)
    link_to "Edit", edit_project_story_path(current_project, story), :class => "form popup edit tip", :title => "edit"
  end

  def link_to_clone_story(story)
    link_to "Clone", clone_project_story_path(current_project, story)
  end

  def link_to_move_story_up(story)
    link_to "Move Up", move_up_project_story_path(current_project, story)
  end

  def link_to_move_story_down(story)
    link_to "Move Down", move_down_project_story_path(current_project, story)
  end

  def link_to_edit_story_position(story)
    link_to "Insert At", edit_numeric_priority_project_story_path(current_project, story), :class => "form popup"
  end

  def link_to_delete_story(story)
    link_to "Delete", project_story_path(current_project, story), :class => "delete popup tip", "data-message" => 'Are you sure you want to delete?<br />All associated data will also be deleted. This action can not be undone.', :title => "delete"
  end

  def link_to_audit_story(story)
    link_to "View History", audit_project_story_path(current_project, story), :class => "view popup tip", :title => "view"
  end
  
end
