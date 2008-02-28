module ProjectsHelper
  def empty_projects_content(&block)
    yield if @projects.empty?
  end
  
  def project_audit_image(project)
    link_to image_tag("xml.gif"), audits_project_path(project)
  end
  
  def project_dashboard_link(project)
    link_to project.name, project_dashboard_path(project)
  end
end
