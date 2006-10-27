class UsersController < ApplicationController
  before_filter :check_authentication, :except => [:login, :authenticate]
  before_filter :require_admin, :except => [:login, :logout, :authenticate,
                                            :no_admin]
  
  
  def index
    list
    render :action => 'list'
  end

  def list
    @user_pages, @users = paginate :user, :per_page => 10
  end

  def show
    @user = User.find(params[:id])
  end
      
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(@params[:id])
    if @session[ :current_user_id ] == @user
      flash[ :error ] = 'You may not delete your own account'
    else
      if User.count('admin = 1') == 1
        flash[ :error ] = 'You may not delete the last admin account'
      else
        User.find(@params[:id]).destroy
        flash[ :notice ] = 'User has been deleted'
      end
    end
    redirect_to :action => 'list'
  end
  
  def login
  end
  
  def authenticate
    if @session[ :current_user_id ] = User.authenticate(@params[ :login ],
                                                        @params[ :password])
      if @session[:return_to]
        redirect_to_path @session[:return_to]
        @session[:return_to] = nil
      else
        redirect_to :controller => 'main', :action => 'dashboard'
      end
    else
      flash[ :error ] = 'You entered an invalid username and/or password.'
      redirect_to :controller => 'users', :action => 'login'
    end
  end

  def logout
    @session[ :current_user_id ] = nil
    redirect_to :controller => 'users', :action => 'login'
    flash[ :notice ] = 'You have been logged out'    
  end
  
  def no_admin
  end
  
  protected

  # Overrides the ApplicationController#require_admin method so that
  # a non-admin user can edit their own account details.
  def require_admin
    case action_name
    when 'edit','update', 'show'
      super if @params['id'].to_i != @session[:current_user_id].id
    else
      super
    end
  end
end
