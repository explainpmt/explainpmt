module UsersHelper
  
  def link_to_new_project_user
    link_to_remote('Create New User', :url => new_project_user_path(@project), :method => :get)
  end

  def link_to_new_user(value)
    link_to_remote(value, :url => new_user_path, :method => :get)
  end

  def link_to_edit_user(user, options={})
    link_to_remote(options[:value] || "Edit", :url => edit_user_path(user), :method => :get)
  end
    
  def link_to_delete_user(user)
    link_to_remote "Delete", :url => user_path(user), :method => :delete, :confirm => "Are you sure you want to delete #{user.full_name}?\r\nAll associated data will also be deleted. This action can not be undone."
  end
  
end
