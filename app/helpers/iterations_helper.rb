module IterationsHelper
  def link_to_new_iteration
    link_to_remote 'New Iteration', :url => new_project_iteration_path(@project), :method => :get
  end
  
  def link_to_current_iteration_in(iterations)
    link_to_unless_current 'Current Iteration', project_iteration_path(@project, iterations.current) if iterations.current
  end

  def link_to_previous_iteration_in(iterations)
    link_to_unless_current 'Previous Iteration', project_iteration_path(@project, iterations.previous) if iterations.previous
  end

  def link_to_next_iteration_in(iterations)
    link_to_unless_current 'Next Iteration', project_iteration_path(@project, iterations.next) if iterations.next
  end
  
  def link_to_edit_iteration(iteration, options={})
    link_to_remote(options[:value] || iteration.name, :url => edit_project_iteration_path(@project, iteration), :method => :get)
  end
  
  def link_to_delete_iteration(iteration)
    link_to "Delete", project_iteration_path(@project, iteration), :method => :delete, :confirm => "Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone."
  end
  
  def link_to_allocation(iteration)
    link_to_remote 'Allocation', :url => allocation_project_iteration_path(@project, iteration), :method => :get
  end
  
  def header_for(iteration)
    "#{iteration.name} (#{numeric_date(iteration.start_date)} - #{numeric_date(@iteration.stop_date)})"
  end
  
end
