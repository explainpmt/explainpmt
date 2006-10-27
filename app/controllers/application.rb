# The filters added to this controller will be run for all controllers in the 
# application.  Likewise will all the methods added be available for all 
# controllers.
class ApplicationController < ActionController::Base
  attr_accessor :current_user
  
  # Method used as a before_filter to restrict access to certain actions.
  def require_admin
    unless current_user.admin?
      flash[:error] = "You must be logged in as an administrator to perform"+
                      " this action"
      redirect_to :controller => 'users', :action => 'no_admin'
      return false
    end
  end
  
  def check_authentication
    if current_user.nil?
      session[:return_to] = request.request_uri
      flash[:status] = "Please log in, and we'll send you right along."
      redirect_to :controller => 'users', :action => 'login'
      return false
    end
  end

  def current_user
    unless session[ :current_user_id ].nil?
      @current_user ||= User.find session[ :current_user_id ]
    end
    @current_user
  end

  def current_user=( user )
    @current_user = user
    if user.nil?
      session[ :current_user_id ] = nil
    else
      session[ :current_user_id ] = user.id
    end
  end
end
