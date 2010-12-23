require 'test_helper'

class IterationsControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:project_iterations)
    should respond_with(:success)
  end
  
  context "on GET to :show" do
    setup do
      get :show, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:iteration)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:iteration)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:iteration)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => @project.id, :iteration => valid_iteration_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => @project.id, :iteration => valid_iteration_params.merge({ :name => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @iteration = Iteration.create(valid_iteration_params)
        put :update, :project_id => @project.id, :iteration => { :name => "changin names" }, :id => @iteration.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @iteration = Iteration.create(valid_iteration_params)
        put :update, :project_id => @project.id, :iteration => { :name => nil }, :id => @iteration.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @iteration = iterations(:iteration_one)
      delete :destroy, :project_id => @project.id, :id => @iteration.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_iteration_params(opts={})
    opts.reverse_merge({
      :project_id => 1,
      :name => "nifty iteration",
      :start_date => Date.today+3.months,
      :length => 7,
      :budget => 22
    })
  end
  
end
