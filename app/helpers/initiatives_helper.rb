module InitiativesHelper
  def link_to_new_initiative
    link_to_remote 'New Initiative', :url => new_project_initiative_path(@project), :method => :get
  end
  
  def link_to_edit_initiative(initiative, options={})
    link_to_remote(options[:value] || initiative.name, :url => edit_project_initiative_path(initiative.project, initiative), :method => :get)
  end
  
  def link_to_delete_initiative(initiative)
    link_to "Delete", project_initiative_path(@project, initiative), :method => :delete, :confirm => "Are you sure you want to delete?"
  end
end
