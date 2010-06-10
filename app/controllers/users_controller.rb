class UsersController < ApplicationController
  skip_before_filter :check_authentication, :only => [:authenticate, :login, :new, :create, :register, :forgot, :password_reset_confirmation]
  skip_before_filter :require_current_project
  before_filter :find_user, :only => [:edit, :update, :destroy, :remove_from_project]

  def index
    @users = User.find(:all, :order => 'last_name ASC, first_name ASC')
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
    if current_user
      redirect_to dashboards_path
    else
      render :layout => false
    end    
  end

  def logout
    session[:current_user] = nil
    redirect_to login_users_path
  end

  def authenticate
    session[:current_user] = User.authenticate(params[:username], params[:password])
    if session[:current_user]
      u = User.find(session[:current_user])
      u.last_login = DateTime::now
      u.save!
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

  def forgot
    render :update do |page|
      if request.post?
        user = User.find(:first, :conditions => ["lower(username) = ?", params[:user][:username].downcase]) unless params[:user][:username].blank?
        user = User.find(:first, :conditions => ["lower(email) = ?", params[:user][:email].downcase]) unless user
        if user && Mailer.deliver_forgot_password(user, request.host_with_port)
          flash[:status] = "Password Reset Sent!"
          page.redirect_to login_users_path
        else
          page[:flash_notice].replace_html :inline => "<%= error_container('Could not find user with supplied information. Please try again.') %>"
        end
      else
        page.call 'showPopup', render(:partial => 'users/forgot')
      end
    end
  end

  def password_reset_confirmation
    user = User.find(params[:id])
    if user.temp_password == params[:auth]
      user.password = user.encrypt(user.temp_password)
      user.temp_password = nil
      user.save_with_validation false
      flash[:status] = 'Your password has been reset.'
    else
      flash[:status] = 'We are unable to reset your password. Please reset your password again.'
    end
      redirect_to login_users_path
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
