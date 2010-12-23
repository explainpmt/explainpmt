class UsersController < ApplicationController
  
  skip_before_filter :require_user, :only => [:new, :forgot_password, :reset_password]

  def index
    @users = User.order("last_name ASC, first_name ASC").paginate(default_paging)
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def edit
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      render_success("User successfully created.") { redirect_to users_path }
    else
      render_errors(@user.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      render_success("User successfully updated.") { redirect_to users_path }
    else
      render_errors(@user.errors.full_messages.to_sentence) { render :edit }
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user == current_user
      flash[:error] = "You cannot delete your own account."
    else
      respond_to do |format|
        if @user.destroy
          success_message = "User account for #{@user.full_name} has been deleted."
          format.html { flash[:success] = success_message }
          format.js { render :text => success_message }
        else
          format.html { flash[:error] = @user.errors.full_messages.to_sentence }
          format.js { render :text => @user.errors.full_messages.to_sentence}
        end
      end
    end
  end
  
  def forgot_password
    if request.post?
      u = User.where("email=?", params[:email]).first
      if u and u.reset_perishable_token!
        Mailer.password_reset_instructions(u).deliver
        flash[:success] = "Check your email for a link to reset password"
        redirect_to login_path
      else
        flash[:error]  = "We couldn't find a user with the email address given."
      end
    end
  end
  
  def reset_password
    @user = User.find_using_perishable_token(params[:token])  
    unless @user
      flash[:error] = "We're sorry, but we could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "reset password process."  
      redirect_to login_path
    else
      if request.put?
        if @user.update_attributes(params[:user])
          flash[:success] = "Your password has successfully been reset. Please login using your new password."
          redirect_to login_path
        else
          flash[:error] = "We were unable to reset your password."
          redirect_to forgot_password_users_path
        end
      end
    end
  end

end
