module UsersHelper
  
  def link_to_new_project_user
    link_to 'Create New User', new_project_user_path(current_project)
  end

  def link_to_new_user(value)
    link_to value, new_user_path
  end

  def link_to_forgot
    link_to "Forgot Password?", forgot_password_users_path
  end

  def link_to_edit_user(user, options={})
    link_to (options[:text] || "Edit"), edit_user_path(user)
  end

  def link_to_delete_user(user)
    link_to "Delete", user_path(user), :method => :delete, :confirm => "Are you sure you want to delete #{user.full_name}?\r\nAll associated data will also be deleted. This action can not be undone."
  end
  
end
