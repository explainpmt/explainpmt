module ReleasesHelper
  def empty_releases_content(&block)
    yield if @releases.empty?
  end

  def link_to_new_release
    link_to 'Add a Release', new_project_release_path(@project)
  end

  def link_to_edit_release(release, options={})
    link_to (options[:text] || release.name), edit_project_release_path(@project, release)
  end
  
  def link_to_assign_release_stories(release)
    link_to 'Assign Story Cards', select_stories_project_release_path(@project, release)
  end

  def option_to_edit_release(release)
    create_action_option("Edit", edit_project_release_path(@project, release))
  end

  def option_to_delete_release(release)
    create_action_option("Delete", project_release_path(@project, release), :method => :delete, :confirm => 'Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone.')
  end
  
  def link_to_release(release)
    link_to release.name, project_release_path(@project, release)
  end
  
  def show_formatted_pending_stories
    if @release_points_non_completed > 0
      "<span class=\"notice_mod\">#{@release_points_non_completed}</span>"
    end
  end
  
  def show_formatted_complete_stories
    if @release_points_completed
    "<span class=\"notice_low\">#{@release_points_completed}</span>"
    end
  end
  
  def show_formatted_non_estimated_stories
    if @num_non_estimated_stories > 0
    "<span class=\"notice_sev\">#{@num_non_estimated_stories}</span>"
    end
  end
end
