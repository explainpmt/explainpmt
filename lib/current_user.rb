module CurrentUser
  
  def self.included(base)
    base.send :helper_method, :current_user
  end
  
  def current_user
    session[:current_user]
  end
  
end