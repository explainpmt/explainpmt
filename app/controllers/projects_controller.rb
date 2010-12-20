class ProjectsController < ApplicationController
  skip_before_filter :check_authentication, :only => :audits
  skip_before_filter :require_current_project
  before_filter :find_project, :except => [:index, :new, :create,]

  def index
    respond_to do |format|
      format.html {
        @projects = current_user.admin? ? Project.all(:order => 'name ASC') : current_user.projects
      }
      format.xml {
        @projects = Project.find(:all)
        render :xml => @projects.to_xml(:include => :iterations)
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        redirect_to project_path(@project)
      }
      format.xml {
        render :xml => @project.to_xml(:include => :iterations)
      }
    end
  end

  def team
    respond_to do |format|
      format.html {@users = @project.users}
      format.js {
        render :update do |page|
          page.redirect_to team_project_path(@project)
        end
      }
    end
  end

  def new
    render :update do |page|
      page.call 'showPopup', render(:partial => 'project_form', :locals => {:url => projects_path})
    end
  end

  def create
    @project = Project.new params[:project]
    render :update do |page|
      if @project.save
        current_user.projects << @project if params[:add_me] == '1'
        flash[:status] = "New project \"#{@project.name}\" has been created."
        page.redirect_to projects_path
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@project.errors.full_messages[0]) %>"
      end
    end
  end

  def edit
    render :update do |page|
      page.call 'showPopup', render(:partial => 'project_form', :locals => {:url => project_path(@project)})
    end
  end

  def update
    render :update do |page|
      if @project.update_attributes(params[:project])
        flash[:status] = "Project \"#{@project.name}\" has been updated."
        page.redirect_to projects_path
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@project.errors.full_messages[0]) %>"
      end
    end
  end

  def destroy
    render :update do |page|
      @project.destroy
      flash[:status] = "#{@project.name} has been deleted."
      page.redirect_to projects_path
    end
  end

  def add_users
    @available_users = @project.users_available_for_addition
    render :update do |page|
      page.call 'showPopup', render(:partial => 'add_users')
    end
  end

  def update_users
    users_added = []
    (params[:selected_users] || []).each do |uid|
      user = User.find_by_id(uid)
      if user
        @project.users << user
        users_added << user.full_name
      end
    end
    flash[:status] = "The following users were added to the project: " + users_added.join(', ') unless users_added.empty?
    redirect_to team_project_path(@project)
  end

  def audits
    @audits = Audit.find(:all, :conditions => ["project_id = #{params[:id]} AND object = 'Story'"], :order => "created_at DESC")
    render :layout => false
  end

  def xml_export
    respond_to do |format|
      format.js{
        render :update do |page|
         page.redirect_to formatted_xml_export_project_path(@project, :xml)
        end
      }
      format.html{redirect_to formatted_xml_export_project_path(@project, :xml)}
      format.xml{render :xml => @project.to_xml(:include => { :iterations => { :include => { :stories => { :include => [:tasks, :acceptance_tests] } } } })  }
    end
  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

end