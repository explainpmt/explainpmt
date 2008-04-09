class UsersController < ApplicationController
  skip_before_filter :check_authentication, :only => [:authenticate, :login, :new, :create, :register]
  skip_before_filter :require_current_project
  before_filter :find_user, :only => [:edit, :update, :destroy, :remove_from_project]

  def index
    @users = User.find(:all, :order => 'last_name ASC, first_name ASC',:page => {:size => 50, :current => params[:page]})
  end

  def new
    url = params[:project_id] ? project_users_path(@project) : users_path
    common_popup(url)
  end

  def edit
    @user.password = nil
    common_popup(user_path(@user))
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
    @user.attributes = params[:user]
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
    redirect_to request.referer
  end

  def login
    render :layout => false
  end

  def logout
    session[:current_user] = nil
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

  def remove_from_project
    @project.users.delete(@user)
    flash[:status] = "#{@user.full_name} has been removed from the project."
    redirect_to team_project_path(@project)
  end

  protected

  def find_user
    @user = User.find params[:id]
  end

  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'users/user_form', :locals => {:url => url})
    end
  end
end
