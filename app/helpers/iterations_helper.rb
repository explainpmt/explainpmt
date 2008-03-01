module IterationsHelper
  def link_to_new_iteration
    link_to_remote 'New Iteration', :url => new_project_iteration_path(@project), :method => :get
  end
  
  def link_to_iteration(iteration)
    link_to iteration.name, project_iteration_path(@project, iteration)
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
  
  def link_to_export_iteration_stories(iteration)
    link_to 'Export Stories', export_project_iteration_path(@project, iteration)
  end

  def link_to_export_iteration_tasks(iteration)
    link_to 'Export Tasks', export_tasks_project_iteration_path(@project, iteration)
  end
  
  def link_to_assign_stories(iteration)
    link_to_remote('Assign Story Cards', :url => select_stories_project_iteration_path(@project, iteration), :method => :get)
  end
  
  def link_to_allocation(iteration)
    link_to_remote 'Allocation', :url => allocation_project_iteration_path(@project, iteration), :method => :get
  end
  
  def header_for(iteration)
    "#{iteration.name} (#{numeric_date(iteration.start_date)} - #{numeric_date(@iteration.stop_date)})"
  end
  
  def iteration_select_list_for(iterations, default)
    options = "<option vlaue='0'>#{default}</option>"
    iterations.unshift(iterations.current) if iterations.current
    iterations.delete_at(0)
    iterations.reverse_each do |i|
      options << "<option value='#{i.id}'>#{i.name}</option>"
    end  
    options
  end
  
end
