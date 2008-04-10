module AcceptancetestsHelper
  def link_to_new_acceptancetest
    link_to_remote('New Acceptance Test', :url => new_project_acceptancetest_path(@project), :method => :get)
  end

  def link_to_edit_acceptancetest(acceptancetest, options={})
    link_to_remote(options[:value] || acceptancetest.name, :url => edit_project_acceptancetest_path(@project, acceptancetest), :method => :get)
  end

  def option_to_edit_acceptancetest(acceptancetest, options={})
    create_action_option(options[:value] || acceptancetest.name, edit_project_acceptancetest_path(@project, acceptancetest))
  end

  def option_to_delete_acceptancetest(acceptancetest)
    create_action_option("Delete", project_acceptancetest_path(@project, acceptancetest), :method => :delete, :confirm => "Are you sure you want to delete?")
  end

  def option_to_clone_acceptancetest(acceptancetest)
    create_action_option("Clone", clone_acceptance_project_acceptancetest_path(@project, acceptancetest)) unless acceptancetest.story_id.blank?
  end

  def link_to_acceptancetest(acceptancetest, options={})
    link_to_remote(options[:value] || acceptancetest.name, :url => project_acceptancetest_path(@project, acceptancetest), :method => :get)
  end

  def link_to_export_acceptance
    link_to('export', export_project_acceptancetests_path(@project))
  end
end
