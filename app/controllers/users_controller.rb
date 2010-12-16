class UsersController < ApplicationController

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

    respond_to do |format|
      if @user.save
        format.html
        format.xml { render :xml => @user, :status => 200 }
      else
        format.html { render :new }
        format.js { render :new, :layout => false }
        format.xml { render :xml => @user.errors, :status => 406 }
      end
    end
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html
        format.xml { render :xml => @user, :status => 200 }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false }
        format.xml { render :xml => @user.errors, :status => 406 }
      end
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
          format.html { flash[:notice] = success_message }
          format.js { render :text => success_message }
        else
          format.html { flash[:notice] = @user.errors.full_messages.to_sentence }
          format.js { render :text => @user.errors.full_messages.to_sentence}
        end
      end
    end
  end

end
