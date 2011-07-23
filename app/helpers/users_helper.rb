module UsersHelper
  
  def link_to_new_project_user
    link_to 'Create New User', new_user_project_path(current_project), :class => "form popup"
  end

  def link_to_new_user(value)
    link_to value, new_user_path, :class => "form popup"
  end

  def link_to_forgot
    link_to "Forgot Password?", forgot_password_users_path
  end

  def link_to_edit_user(user, options={})
    link_to (options[:text] || "Edit"), edit_user_path(user), :class => "form popup edit tip", :title => "edit"
  end

  def link_to_delete_user(user)
    link_to "Delete", user_path(user), :class => "delete popup tip", "data-message" => "Are you sure you want to delete #{user.full_name}?<br />All associated data will also be deleted. This action can not be undone.", :title => "delete"
  end
  
end
