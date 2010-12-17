class TasksController < ApplicationController
  before_filter :find_task, :except => [:new, :create]

  def new
    @story = Story.find params[:story_id]
    @task = Task.new
  end

  def edit
  end

  def create
    @story = Story.find(params[:story_id])
    @task = @story.tasks.build(params[:task])
    
    respond_to do |format|
      if @task.save
        msg = "New Task \"#{@task.name}\" has been created."
        format.html {
          flash[:success] = msg
          redirect_to project_story_tasks_path(@project, @story)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @task.errors.full_messages.to_sentence
        format.html {
          flash[:errors] = msg
          render :new
        }
        format.js { render :json => { :errors => msg } }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update_attributes(params[:task])
        msg = "Task \"#{@task.name}\" has been updated."
        format.html {
          flash[:success] = msg
          redirect_to project_story_tasks_path(@project, @story)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @task.errors.full_messages.to_sentence
        format.html {
          flash[:errors] = msg
          render :edit
        }
        format.js { render :json => { :errors => msg } }
      end
    end
  end

  def destroy
    @task.destroy
    flash[:success] = "Task \"#{@task.name}\" has been deleted."
    redirect_to request.referer
  end

  def take_ownership
    @task.assign_to(current_user)
    redirect_to request.referer
  end

  def release_ownership
    @task.release_ownership
    redirect_to request.referer
  end

  def assign_ownership
    @users = @project.users
    render :partial => "assign_owner_form"
  end

  def assign
    @task.assign_to(User.find params[:owner][:id])
    redirect_to request.referer
  end

  protected

  def find_task
    @task = Task.find params[:id]
  end

end
