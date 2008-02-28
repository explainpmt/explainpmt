module AcceptancetestsHelper
  
  def link_to_export_acceptance
    link_to('Export Acceptance Tests', export_project_acceptancetests_path(@project))
  end
end
