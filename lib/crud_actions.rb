module CrudActions
  def index
    @list = mymodel.find(:all, :conditions => [ "project_id = (?)", @project.id] )
  end

  def edit
    @object = mymodel.find params[:id]
    @page_title = "Edit #{mymodel}"
  end
  
  def new
    @object = mymodel.new
    @page_title = "New #{mymodel}"
  end

  def create
    @object = mymodel.new params[:object]
    @object.project = @project if @object.has_attribute?(:project_id)
    if @object.valid?
      @object.save
      current_user.projects << object_to_create if mymodel.name == "Project" && params[:add_me] == '1'
      flash[:status] = "#{mymodel} \"#{@object.name}\" has been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "new", :layout => "popup"
    end
  end
  
  def update
    @object = mymodel.find params[:id]
    if @object.update_attributes params[:object]
      flash[:status] = "Changes to \"#{@object.name}\" have been been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "edit", :layout => "popup"
    end
  end
  
  def show
    @object = mymodel.find params[:id]
  end
   
  def delete
    object_selected = mymodel.find params[:id]
    object_selected.destroy
    flash[:status] = "#{mymodel.name} \"#{object_selected.name}\" has been deleted."
    redirect_to :action => 'index', :project_id => @project.id
  end
  
  def export
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @list = mymodel.find(:all, :conditions => [ "project_id = ?", @project.id] )
    render :layout => false
  end
end