class TasksController < ApplicationController
  
  def new
    @story = Story.find params[:story_id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'story_task_form', :locals => {:url => project_story_tasks_path(@project)})
      page.call 'autoFocus', "task_name", 500
    end 
  end

  def edit
    @task = Task.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'story_task_form', :locals => {:url => project_story_task_path(@project, @task.story, @task)})
      page.call 'autoFocus', "task_name", 500
    end 
  end

  def show
    @task = Task.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'tasks/show')
    end 
  end
  
  def create
    task = Task.new params[:task]
    task.story = Story.find(params[:story_id])
    render :update do |page|
      if task.save
        flash[:status] = "New Task \"#{task.name}\" has been created."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html task.errors.full_messages[0]
      end
    end  
  end
 
  def update
    task = Task.find params[:id]
    render :update do |page|
      if task.update_attributes(params[:task])
        flash[:status] = "Task \"#{task.name}\" has been updated."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html task.errors.full_messages[0]
      end
    end
  end
  
  def destroy
    task = Task.find params[:id]
    render :update do |page|
      if task.destroy
        flash[:status] = "Task \"#{task.name}\" has been deleted."
        page.call 'location.reload'
      end
    end
  end
  
  def take_ownership
    task = Task.find params[:id]
    task.owner = current_user
    task.save
    current_user.reload
    render :update do |page|
      page.call 'location.reload'
    end
  end

  def release_ownership
    task = Task.find params[:id]
    task.owner = nil
    task.save
    current_user.reload
    render :update do |page|
      page.call 'location.reload'
    end
  end
  
  def assign_ownership
    @task = Task.find params[:id]
    @users = @project.users
    render :update do |page|
      page.call 'showPopup', render(:partial => 'assign_owner_form')
    end 
  end
  
  def assign
    task = Task.find params[:id]
    user = User.find params[:owner][:id]
    task.owner = user
    task.save
    current_user.reload
    render :update do |page|
      page.call 'location.reload'
    end
  end

end
