class TasksController < WizardController
  popups :new, :create, :edit, :show, :assign_owner

  def mymodel
   Task
  end
  
  def new
    @story = Story.find(params[:id])
    super 
  end
  
  def create
    object_to_create = mymodel.new(params[:object])
    object_to_create.story = Story.find(params[:story_id])
    if object_to_create.valid?
      object_to_create.save
      flash[:status] = "#{mymodel} \"#{object_to_create.name}\" has been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      session[:new_object] = object_to_create
      redirect_to :action => 'new', :project_id => @project.id, 
                  :id => object_to_create.story_id
    end
  end
 
  def delete
    myobject = mymodel.find(params[:id])
    myobject.destroy
    flash[:status] = "#{mymodel.name} \"#{myobject.name}\" has been deleted."
    redirect_to :controller => 'stories', :action => 'show', 
                  :id => myobject.story_id,
                  :project_id => @project.id
  end
 
  def take_ownership
    story = Story.find(params[:story_id])
    task = Task.find(params[:id])
    task.owner = session[:current_user]
    task.save
    session[:current_user].reload
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'stories', :action => 'show',
                :id => story.id, :project_id => @project.id
  end

  def assign_owner
    @object = Task.find(params[:id])
    @users = @project.users
  end
  
    # Sets the story's owner to nil
  def release_ownership
    story = Story.find(params[:story_id])
    task = Task.find(params[:id])
    task.owner = nil
    task.save
    session[:current_user].reload
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'stories', :action => 'show',
                :id => story.id, :project_id => @project.id
  end
end
