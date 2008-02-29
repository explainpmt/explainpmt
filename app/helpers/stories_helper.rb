module StoriesHelper
  def link_to_new_story
    link_to_remote('Create Story Card', :url => new_project_story_path(@project), :method => :get)
  end
  
  def link_to_story_with_sc(story)
    link_to("SC#{story.scid}", project_story_path(@project, story)) + '(' + truncate(story.title, 30) + ')'
  end
  
  def link_to_story(story, options={})
    link_to(options[:value] || story.title, project_story_path(@project, story))
  end

  def link_to_edit_story(story, options={})
    link_to_remote(options[:value] || story.title, :url => edit_project_story_path(@project, story), :method => :get)
  end

  def link_to_clone_story(story)
    link_to_remote("Clone", :url => clone_story_project_story_path(@project, story), :method => :put)
  end

  def link_to_move_story_up(story)
    link_to_remote("Move Up", :url => move_up_project_story_path(@project, story), :method => :put)
  end

  def link_to_move_story_down(story)
    link_to_remote("Move Down", :url => move_down_project_story_path(@project, story), :method => :put)
  end

  def link_to_edit_story_position(story)
    link_to_remote("Insert At", :url => edit_numeric_priority_project_story_path(@project, story), :method => :get)
  end
  
  def link_to_delete_story(story)
    link_to_remote("Delete", :url => project_story_path(@project, story), :method => :delete, :confirm => "Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone.")
  end
  
  def link_to_assign_story_ownership(story)
    link_to_remote('assign', :url => assign_ownership_project_story_path(@project, story), :method => :get)
  end

  def link_to_take_story_ownership(story)
    link_to_remote('take', :url => take_ownership_project_story_path(@project, story), :method => :put)
  end

  def link_to_release_story_ownership(story)
    link_to_remote('release', :url => release_ownership_project_story_path(@project, story), :method => :put)
  end

  def link_to_new_acceptance_for(story)
    link_to_remote('Add Acceptance', :url => new_project_story_acceptancetest_path(@project, story), :method => :get)
  end
  
  def link_to_audit_story(story)
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
