module AcceptanceTestsHelper
  
  def link_to_new_acceptance_test
    link_to 'New Acceptance Test', new_project_acceptance_test_path(@project)
  end

  def link_to_edit_acceptance_test(acceptance_test, options={})
    link_to (options[:text] || acceptance_test.name), edit_project_acceptance_test_path(@project, acceptance_test)
  end

  def option_to_edit_acceptance_test(acceptance_test)
    create_action_option("Edit", edit_project_acceptance_test_path(@project, acceptance_test))
  end

  ## TODO => make this non-remote.
  def option_to_delete_acceptance_test(acceptance_test)
    create_action_option("Delete", project_acceptance_test_path(@project, acceptance_test), :method => :delete, :confirm => "Are you sure you want to delete?")
  end

  def option_to_clone_acceptance_test(acceptance_test)
    create_action_option("Clone", clone_acceptance_project_acceptance_test_path(@project, acceptance_test)) unless acceptance_test.story_id.blank?
  end

  def link_to_acceptance_test(acceptance_test, options={})
    link_to (options[:text] || acceptance_test.name), project_acceptance_test_path(@project, acceptance_test)
  end

  def link_to_export_acceptance
    link_to 'export', export_project_acceptance_tests_path(@project)
  end
  
end
