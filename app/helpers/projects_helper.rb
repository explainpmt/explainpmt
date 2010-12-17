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
    link_to project.name, project_dashboard_path(project)
  end

  def option_to_view_team(project)
    create_action_option("View Team", team_project_path(project))
  end

  def option_to_edit_project(project)
    create_action_option("Edit", edit_project_path(project))
  end

  def option_to_delete_project(project)
    create_action_option("Delete", project_path(project), :method => :delete, :confirm => 'Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone.')
  end
  def option_to_export_project(project)
    create_action_option("Export", xml_export_project_path(project), :method => :get)
  end

  def link_to_remove_user(user)
    link_to "Remove From Project", remove_from_project_project_user_path(@project, user), :method => :put
  end

  def link_to_add_users
    link_to "Add Users to Project", add_users_project_path(@project)
  end
end
