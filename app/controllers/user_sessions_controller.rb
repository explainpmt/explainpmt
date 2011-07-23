class UserSessionsController < ApplicationController
  layout 'login'
  
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    if logged_in?
      redirect_to root_url
    else
      @user_session = UserSession.new
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to "/"
    else
      flash[:notice] = "There was a problem logging you in."
      render :new
    end
  end

  def destroy
    current_user_session.destroy if current_user_session
    redirect_to "/"
  end

end
