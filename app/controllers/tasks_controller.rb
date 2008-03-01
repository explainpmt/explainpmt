class TasksController < ApplicationController
  before_filter :find_task, :except => [:new, :create]

  def new
    @story = Story.find params[:story_id]
    common_popup(project_story_tasks_path(@project))
  end

  def edit
    common_popup(project_story_task_path(@project, @task.story, @task))
  end

  def show
    render :update do |page|
      page.call 'showPopup', render(:partial => 'tasks/show')
    end 
  end
  
  def create
    @task = Task.new params[:task]
    @task.story = Story.find(params[:story_id])
    render :update do |page|
      if @task.save
        flash[:status] = "New Task \"#{@task.name}\" has been created."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@task.errors.full_messages[0]) %>"   
      end
    end  
  end
 
  def update
    render :update do |page|
      if @task.update_attributes(params[:task])
        flash[:status] = "Task \"#{@task.name}\" has been updated."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@story.errors.full_messages[0]) %>"   
      end
    end
  end
  
  def destroy
    if @task.destroy
      flash[:status] = "Task \"#{@task.name}\" has been deleted."
      redirect_to request.referer
    end
  end
  
  def take_ownership
    @task.owner = current_user
    @task.save
    current_user.reload
    redirect_to request.referer
  end

  def release_ownership
    @task.owner = nil
    @task.save
    current_user.reload
    redirect_to request.referer
  end
  
  def assign_ownership
    @users = @project.users
    render :update do |page|
      page.call 'showPopup', render(:partial => 'assign_owner_form')
    end 
  end
  
  def assign
    user = User.find params[:owner][:id]
    @task.owner = user
    @task.save
    current_user.reload
    redirect_to request.referer
  end
  
  protected
  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'story_task_form', :locals => {:url => url})
    end    
  end
  
  def find_task
    @task = Task.find params[:id]
  end

end
