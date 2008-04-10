module ReleasesHelper
  def empty_releases_content(&block)
    yield if @releases.empty?
  end

  def link_to_new_release
    link_to_remote 'Add a Release', :url => new_project_release_path(@project), :method => :get
  end

  def link_to_edit_release(release, options={})
    link_to_remote(options[:value] || release.name, :url => edit_project_release_path(@project, release), :method => :get)
  end

  def option_to_edit_release(release)
    create_action_option("Edit", edit_project_release_path(@project, release))
  end

  def option_to_delete_release(release)
    create_action_option("Delete", project_release_path(@project, release), :method => :delete, :confirm => 'Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone.')
  end
end
