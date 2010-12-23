require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index
    end
    
    should assign_to(:projects)
    should respond_with(:success)
  end
  
  context "on GET to :new" do
    setup do
      get :new
    end
    
    should assign_to(:project)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1
    end
    
    should assign_to(:project)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project => valid_project_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project => valid_project_params.merge({ :name => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @project = Project.create(valid_project_params)
        put :update, :project => { :name => "changin names" }, :id => @project.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @project = Project.create(valid_project_params)
        put :update, :project => { :name => nil }, :id => @project.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @project = projects(:awesome)
      delete :destroy, :id => @project.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_project_params(opts={})
    opts.reverse_merge({
      :name => "nifty project",
      :description => "cool beans",
      :planned_iterations => 4
    })
  end
  
end
