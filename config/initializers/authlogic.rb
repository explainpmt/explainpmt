module Authlogic

  def self.included(base)
    base.send :before_filter, :activate_authlogic if base.respond_to? :before_filter
    base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def require_user
    unless current_user
      store_location
      flash[:warning] = "You must be logged in to access this page"
      redirect_to login_path
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:warning] = "You must be logged out to access this page"
      redirect_to dashboard_path
      return false
    end
  end

  def single_access_allowed?
    true
  end

  def login_from_token
    return unless params[:auth].present?
    u = User.find_by_perishable_token(params[:auth])
    UserSession.create(u) if u
    redirect_to "/"
  end
    
end