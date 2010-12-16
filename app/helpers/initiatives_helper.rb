module InitiativesHelper
  def link_to_new_initiative
    link_to 'New Initiative', new_project_initiative_path(@project)
  end

  def link_to_edit_initiative(initiative, options={})
    link_to (options[:text] || initiative.name), edit_project_initiative_path(initiative.project, initiative)
  end

  def option_to_edit_initiative(initiative)
    create_action_option("Edit", edit_project_initiative_path(initiative.project, initiative))
  end

  def option_to_delete_initiative(initiative)
    create_action_option("Delete", project_initiative_path(@project, initiative), :method => :delete, :confirm => "Are you sure you want to delete?")
  end
end
