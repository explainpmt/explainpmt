module ReleasesHelper

  def link_to_new_release
    link_to "Add a Release", new_project_release_path(current_project), :class => "form popup new"
  end

  def link_to_edit_release(release, options={})
    link_to "Edit", edit_project_release_path(current_project, release), :class => "form popup edit tip", :title => "edit"
  end

  def link_to_assign_release_stories(release)
    link_to "Assign Story Cards", select_stories_project_release_path(current_project, release)
  end

  def link_to_delete_release(release)
    link_to "Delete", project_release_path(current_project, release), :class => "delete popup tip", "data-message" => "Are you sure you want to delete?<br />All associated data will also be deleted. This action can not be undone.", :title => "delete"
  end

  def link_to_release(release)
    link_to release.name, project_release_path(current_project, release)
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
