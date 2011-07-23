module InitiativesHelper
  def link_to_new_initiative
    link_to 'New Initiative', new_project_initiative_path(current_project), :class => "new popup"
  end

  def link_to_edit_initiative(initiative, options={})
    text = options.delete(:text) || initiative.name
    link_opts = options.reverse_merge(:class => "edit popup tip", :title => "edit")
    link_to text, edit_project_initiative_path(initiative.project, initiative), link_opts
  end

  def link_to_delete_initiative(initiative)
    link_to "Delete", project_initiative_path(current_project, initiative), :class => "delete popup tip", "data-message" => "Are you sure you want to delete?", :title => "delete"
  end
end
