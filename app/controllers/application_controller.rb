class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  helper_method :current_user, :logged_in?
  
  before_filter :correct_safari_and_ie_accept_headers
  before_filter { |c| User.current_user = c.current_user if c.current_user }
  before_filter { |c| (c.action_has_layout = false) if c.request.xhr? }
  
  before_filter :set_selected_project
  
  def correct_safari_and_ie_accept_headers
    ajax_request_types = ['text/javascript', 'application/json', 'text/xml']
    request.accepts.sort!{ |x, y| ajax_request_types.include?(y.to_s) ? 1 : -1 } if request.xhr?
  end
  
  def current_user=(user)
    @current_user = user
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def local_request?
    %w(staging).include?(Rails.env) || super
  end
  
  def default_paging
    { :page => params[:page], :per_page => 50 }
  end
  
  protected
  
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
      flash[:warning] = "Please login to access mobile banking features."
      redirect_to "/login"
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def set_selected_project
    @project = params[:project_id] ? Project.find_by_id(params[:project_id]) : current_user.projects.first
  end
end
