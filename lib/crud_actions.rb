module CrudActions
  def edit
    @object = session[:edit_object] || mymodel.find(params[:id])
    session[:edit_object] = nil
    @page_title = "Edit #{mymodel}"
  end
  
  def new
    @object = session[:new_object] || mymodel.new
    session[:new_object] = nil
    @page_title = "New #{mymodel}"
  end

  def create
    object_to_create = mymodel.new(params[:object])
    object_to_create.project = @project if object_to_create.has_attribute?(:project_id)
    if object_to_create.valid?
      object_to_create.save
      if mymodel.name == "Project" && params[:add_me] == '1'
        session[:current_user].projects << object_to_create
      end
      flash[:status] = "#{mymodel} \"#{object_to_create.name}\" has been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      session[:new_object] = object_to_create
      redirect_to :action => 'new',:project_id => @project.id
    end
  end
  
  def update
    ojbect_to_edit = mymodel.find(params[:id])
    if ojbect_to_edit.update_attributes(params[:object])
      flash[:status] = "Changes to \"#{ojbect_to_edit.name}\" have been been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      session[:edit_object] = ojbect_to_edit
      redirect_to :action => 'edit', :id => ojbect_to_edit.id,
      :project_id => @project.id
    end
  end
  
  def show
    @object = mymodel.find(params[:id])
  end
   
  def delete
    object_selected = mymodel.find(params[:id])
    object_selected.destroy
    flash[:status] = "#{mymodel.name} \"#{object_selected.name}\" has been deleted."
    redirect_to :action => 'index', :project_id => @project.id
  end
end