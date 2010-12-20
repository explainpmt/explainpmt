require 'test_helper'

class AcceptanceTestsControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:acceptance_tests)
    should respond_with(:success)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:acceptance_test)
  end
  
  context "on GET to :show" do
    setup do
      get :show, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:acceptance_test)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:acceptance_test)
  end
  
end