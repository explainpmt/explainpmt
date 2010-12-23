class TasksController < ApplicationController
  before_filter :find_task, :except => [:new, :create]

  def new
    @story = Story.find params[:story_id]
    @task = Task.new
  end
  
  def edit
    @story = @task.story
  end

  def create
    @story = Story.find(params[:story_id])
    @task = @story.tasks.build(params[:task])
    
    if @task.save
      render_success("New Task \"#{@task.name}\" has been created.") { redirect_to project_story_tasks_path(current_project, @story) }
    else
      render_errors(@task.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    @story = Story.find(params[:story_id])
    
    if @task.update_attributes(params[:task])
      render_success("Task \"#{@task.name}\" has been updated.") { redirect_to project_story_tasks_path(current_project, @story) }
    else
      render_errors(@task.errors.full_messages.to_sentence) { render :edit }
    end
  end

  def destroy
    @task.destroy
    flash[:success] = "Task \"#{@task.name}\" has been deleted."
    redirect_to request.referer
  end

  def take_ownership
    @task.assign_to!(current_user)
    redirect_to request.referer
  end

  def release_ownership
    @task.release_ownership!
    redirect_to request.referer
  end

  def assign_ownership
    @users = current_project.users
    render :partial => "assign_owner_form"
  end

  def assign
    @task.assign_to!(User.find params[:owner][:id])
    redirect_to request.referer
  end

  protected

  def find_task
    @task = Task.find params[:id]
  end

end
