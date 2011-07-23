module AcceptanceTestsHelper
  
  def link_to_new_acceptance_test
    link_to 'New Acceptance Test', new_project_acceptance_test_path(current_project), :class => "form popup"
  end

  def link_to_edit_acceptance_test(acceptance_test)
    link_to "Edit", edit_project_acceptance_test_path(current_project, acceptance_test), :class => "form popup edit tip", :title => "edit"
  end

  def link_to_delete_acceptance_test(acceptance_test)
    link_to "Delete", project_acceptance_test_path(current_project, acceptance_test), :class => "delete popup tip", :title => "delete"
  end

  def link_to_clone_acceptance_test(acceptance_test)
    link_to "Clone", clone_acceptance_project_acceptance_test_path(current_project, acceptance_test), :class => "view popup tip", :title => "clone" unless acceptance_test.story_id.blank?
  end

  def link_to_acceptance_test(acceptance_test, options={})
    link_to (options[:text] || acceptance_test.name), project_acceptance_test_path(current_project, acceptance_test), :class => "show popup"
  end

  def link_to_export_acceptance
    link_to 'export', export_project_acceptance_tests_path(current_project)
  end
  
end
