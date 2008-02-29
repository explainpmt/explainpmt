class UsersController < ApplicationController
  skip_before_filter :check_authentication, :only => [:authenticate, :login, :new, :create, :register]
  skip_before_filter :require_current_project
  before_filter :find_user, :only => [:edit, :update, :destroy]
  
  def index
    @users = User.find(:all, :order => 'last_name ASC, first_name ASC')
  end

  def new
    url = params[:project_id] ? project_users_path(@project) : users_path
    common_popup(url)
  end

  def edit
    @user = User.find params[:id]
    common_popup(project_user_path(@project, @user))
  end

  def create
    @user = User.new params[:user]
    render :update do |page|
      if @user.save
        @user.projects << @project if @project
        flash[:status] = "New User \"#{@user.full_name}\" has been created "
        flash[:status] += @project ? "and added to the project team." : "."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@user.errors.full_messages[0]) %>"
      end
    end
  end

  def update
    original_password = @user.password
    @user.attributes = params[:user]
    @user.password_confirmation = original_password if params[:user][:password_confirmation].blank?
    render :update do |page|
      if @user.save
        flash[:status] = "User account for #{@user.full_name} has been updated."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@user.errors.full_messages[0]) %>"
      end
    end
  end
  
  def destroy
    if @user == @current_user
      flash[:error] = "You can not delete your own account." 
    else
      @user.destroy
      flash[:status] = "User account for #{@user.full_name} has been deleted."
    end
    reload
  end

  def login
    render :layout => false
  end
  
  def logout
    session[:current_user] = nil
    flash[:status] = "You have been logged out."
    redirect_to login_users_path
  end  
  
  def authenticate
    session[:current_user] = User.authenticate(params[:username], params[:password])
    if session[:current_user]
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to dashboards_path
      end
    else
      flash[:error] = 'You entered an invalid username and/or password.'
      redirect_to login_users_path
    end
  end
  
  protected
  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'users/user_form', :locals => {:url => url})
    end 
  end
  
  def find_user
    @user = User.find params[:id]
  end
  
end
