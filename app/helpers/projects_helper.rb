module ProjectsHelper
  
  def empty_projects_content(&block)
    yield if @projects.empty?
  end

  def project_audit_image(project)
    link_to image_tag("rss_small.png"), audits_project_path(project)
  end
  
  def project_export_image(project)
    link_to image_tag("xml.gif"), xml_export_project_path(project)
  end

  def project_dashboard_link(project)
    link_to project.name, project_path(project)
  end

  def link_to_view_team(project)
    link_to "View Team", team_project_path(project)
  end

  def link_to_edit_project(project)
    link_to "Edit", edit_project_path(project), :class => "form popup"
  end

  def link_to_delete_project(project)
    link_to "Delete", project_path(project), :class => "delete popup", "data-message" => 'Are you sure you want to delete?<br />All associated data will also be deleted. This action can not be undone.'
  end

  def link_to_export_project(project)
    link_to "Export", xml_export_project_path(project)
  end

  def link_to_remove_user(user)
    link_to "Remove From Project", remove_from_project_project_user_path(current_project, user), :method => :put
  end

  def link_to_add_users
    link_to "Add Users to Project", add_users_project_path(current_project)
  end
  
end
