class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password
  helper_method :current_user
  before_filter :check_authentication
  before_filter :set_selected_project
  before_filter :require_team_membership
  before_filter :require_current_project

  def current_user
    @user ||= session[:current_user] && User.find(session[:current_user]) || nil
  end

  protected

  def set_selected_project
    @project = Project.find_by_id(params[:project_id])
  end

  def check_authentication
    unless current_user.kind_of?(User)
      session[:return_to] = request.request_uri
      redirect_to login_users_path
    end
  end

  def require_admin_privileges
    unless current_user.admin?
      flash[:error] = "You must be logged in as an administrator to perform " +
        "the requested action."
      redirect_to errors_path
    end
  end

  def require_team_membership
    if @project and !current_user.admin?
      unless current_user.projects.include?(@project)
        flash[:error] = 'You do not have permission to access the project, ' +
          'because you are not part of the project team.'
        redirect_to errors_path
      end
    end
  end

  def require_current_project
    unless @project
      flash[:error] = "You attempted to access a view that requires a project to be selected"
      redirect_to errors_path
    end
  end

  def set_status_and_error_for(results)
    flash[:status] = results[:successes].join("\n\n") unless results[:successes].empty?
    flash[:error] = results[:failures].join("\n\n") unless results[:failures].empty?
  end


end
