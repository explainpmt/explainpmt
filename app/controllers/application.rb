# The filters added to this controller will be run for all controllers in the 
# application.  Likewise will all the methods added be available for all 
# controllers.
class ApplicationController < ActionController::Base

    
  
  # Method used as a before_filter to restrict access to certain actions.
  def require_admin
    unless @session[:current_user_id].admin?
      flash[:error] = "You must be logged in as an administrator to perform"+
                      " this action"
      redirect_to :controller => 'users', :action => 'no_admin'
      return false
    end
  end
  
  def check_authentication
    unless @session[:current_user_id].kind_of?(User)

      @session[:return_to] = @request.request_uri
      flash[:status] = "Please log in, and we'll send you right along."
      redirect_to :controller => 'users', :action => 'login'
      return false
    end
  end
end