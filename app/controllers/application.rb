class ApplicationController < ActionController::Base
  helper_method :current_user
  before_filter :check_authentication
  before_filter :set_selected_project
  before_filter :require_team_membership
  
  def current_user
    session[:current_user]
  end
  
  protected
  
  def set_selected_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
  end
  
  def check_authentication
    unless current_user.kind_of?(User)
      session[:return_to] = request.request_uri
      flash[:status] = "Please log in, and we'll send you right along."
      redirect_to login_users_path
      return false
    end
  end
  
  def require_admin_privileges
    unless current_user.admin?
      flash[:error] = "You must be logged in as an administrator to perform " +
                      "the requested action."
      redirect_to :controller => 'error', :action => 'index'
      return false
    end
  end
  
  def require_team_membership
    if @project and !current_user.admin?
      unless User.find(current_user.id).projects.include?(@project)
        flash[:error] = 'You do not have permission to access the project, ' +
                        'because you are not part of the project team.'
        redirect_to :controller => 'error', :action => 'index'
        return false
      end
    end
  end
  
  def require_current_project
    unless @project
      flash[:error] = "You attempted to access a view that requires a " +
                      "project to be selected, but no project id was set in " +
                      "your request."
      redirect_to :controller => 'error', :action => 'index'
      return false
    end
  end
  
  def register_referer
    unless request.env['HTTP_REFERER'].blank?
      session[:referer] = request.env['HTTP_REFERER']
    end
  end
  
  def redirect_to_referer
    if session[:referer]
      redirect_to session[:referer]
      session[:referer] = nil
      true
    else
      false
    end
  end
end