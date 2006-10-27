class ProjectsController < ApplicationController
  before_filter :check_authentication
  before_filter :require_admin, :except => [:index, :list, :show, :team]

  def index
    list
    render :action => 'list'
  end

  def list
    @project_pages, @projects = paginate :project, :per_page => 10
    
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to :action => 'show', :id => @project
    else
      render :action => 'edit'
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def team
    @project = Project.find(params[:id])  
    @users = @project.users
  end
  
  def remove_user
    @project = Project.find(params[:id])  
    @project.remove_users(User.find(params[:user_id]))
    redirect_to :action => 'team', :id => @project.id
    flash[:notice] = 'User was successfully removed from the project.'    
  end

### Implemented before the change to the story card.  Currently working on
###  -- Eric 
#  def add_user
#    @project = Project.find(params[:id])
#  end 

end
