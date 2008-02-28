class TasksController < ApplicationController
  
  def new
    @story = Story.find params[:story_id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'story_task_form', :locals => {:url => project_story_tasks_path(@project)})
      page.call 'autoFocus', "task_name", 500
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
 
  def delete
    task = Task.find params[:id]
    task.destroy
    flash[:status] = "Task \"#{task.name}\" has been deleted."
    redirect_to project_story_path(@project, task.story)
  end
  
  def delete_from_dashboard
    myobject = mymodel.find params[:id]
    myobject.destroy
    flash[:status] = "#{mymodel.name} \"#{myobject.name}\" has been deleted."
    redirect_to :controller => 'dashboard', :action => 'index', 
      :project_id => @project.id
  end
 
  def take_ownership
    story = Story.find params[:story_id]
    task = Task.find params[:id]
    task.owner = current_user
    task.save
    current_user.reload
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'stories', :action => 'show',
      :id => story.id, :project_id => @project.id
  end

  def assign_owner
    @object = Task.find params[:id]
    @users = @project.users
  end
  
  def release_ownership
    story = Story.find params[:story_id]
    task = Task.find params[:id]
    task.owner = nil
    task.save
    current_user.reload
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'stories', :action => 'show',
      :id => story.id, :project_id => @project.id
  end
end
