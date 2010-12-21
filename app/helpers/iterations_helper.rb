module IterationsHelper
  def link_to_new_iteration
    link_to 'New Iteration', new_project_iteration_path(current_project)
  end
  
  def link_to_iteration(iteration)
    link_to iteration.name, project_iteration_path(iteration.project, iteration)
  end
  
  def link_to_current_iteration_in(iterations)
    link_to_unless_current 'Current Iteration', project_iteration_path(current_project, iterations.current.first) if iterations.current.present?
  end

  def link_to_previous_iteration_in(iterations)
    link_to_unless_current 'Previous Iteration', project_iteration_path(current_project, iterations.previous.first) if iterations.previous.present?
  end

  def link_to_next_iteration_in(iterations)
    link_to_unless_current 'Next Iteration', project_iteration_path(current_project, iterations.next.first) if iterations.next.present?
  end
  
  def link_to_edit_iteration(iteration, options={})
    link_to (options[:text] || iteration.name), edit_project_iteration_path(current_project, iteration)
  end
  
  def link_to_delete_iteration(iteration)
    link_to "Delete", project_iteration_path(current_project, iteration), :method => :delete, :confirm => "Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone."
  end
  
  def link_to_export_iteration_stories(iteration)
    link_to 'Export Stories', export_project_iteration_path(current_project, iteration)
  end

  def link_to_export_iteration_tasks(iteration)
    link_to 'Export Tasks', export_tasks_project_iteration_path(current_project, iteration)
  end
  
  def link_to_assign_stories(iteration)
    link_to 'Assign Story Cards', select_stories_project_iteration_path(current_project, iteration)
  end
  
  def link_to_allocation(iteration)
    link_to 'Allocation', allocation_project_iteration_path(current_project, iteration)
  end
  
  def header_for(iteration)
    "#{iteration.name} (#{numeric_date(iteration.start_date)} - #{numeric_date(@iteration.stop_date)})"
  end
  
  def iteration_select_list_for(iterations, default)
    iterations.unshift(iterations.current) if iterations.current
    iterations.delete_at(0)
    iterations.reverse.inject("<option value='0'>#{default}</option>") do |options, iteration|
      options << "<option value='#{iteration.id}'>#{iteration.name}</option>"
    end
  end
  
end
