require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @current_user = users(:admin)
    @project = Project.first
  end
  
  context "on GET to :new" do
    setup do
      get :new, :story_id => 1, :project_id => @project.id
    end
    
    should assign_to(:project)
    should assign_to(:story)
    should assign_to(:task)
    
    should respond_with(:success)
    should render_template(:new)
    should_not set_the_flash
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :story_id => 1, :project_id => @project.id
    end
    
    should assign_to(:project)
    should assign_to(:story)
    should assign_to(:task)
    
    should respond_with(:success)
    should render_template(:edit)
    should_not set_the_flash
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => 1, :story_id => 1, :task => { :name => "blah blah", :description => "whatevs", :user_id => @current_user.id }
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => 1, :story_id => 1, :task => { :name => nil }
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @task = Task.create({ :name => "old" })
        put :update, :project_id => 1, :story_id => 1, :task => { :name => "new" }, :id => @task.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @task = Task.create({ :name => "old" })
        put :update, :project_id => 1, :story_id => 1, :task => { :name => nil }, :id => @task.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @task = Task.create({ :name => "blah" })
      delete :destroy, :project_id => 1, :story_id => 1, :id => @task.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  context "on GET to :take_ownership" do
    setup do
      @task = tasks(:unassigned)
      get :take_ownership, :project_id => 1, :story_id => 1, :id => @task.to_param
    end
    
    should respond_with(:redirect)
    should "make the current user the owner" do
      @task.reload
      assert_equal @task.owner, @current_user
    end
  end
  
  context "on GET to :release_ownership" do
    setup do
      @task = tasks(:assigned)
      get :release_ownership, :project_id => 1, :story_id => 1, :id => @task.to_param
    end
    
    should respond_with(:redirect)
    should "set task owner to nil" do
      @task.reload
      assert_nil @task.owner
    end
  end
  
  context "on GET to :assign_ownership" do
    setup do
      @task = tasks(:unassigned)
      get :assign_ownership, :project_id => 1, :story_id => 1, :id => @task.to_param
    end
    
    should respond_with(:success)
    should_not set_the_flash
  end
  
  context "on POST to :assign" do
    setup do
      @task = tasks(:unassigned)
      post :assign, :project_id => 1, :story_id => 1, :id => @task.to_param, :owner => { :id => users(:david).id }
    end
    
    should respond_with(:redirect)
    should "update the task's owner" do
      @task.reload
      assert_equal @task.owner, users(:david)
    end
  end
  
end
