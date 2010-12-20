require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :new" do
    setup do
      get :new, :story_id => 1, :project_id => @project.id
    end
    
    should assign_to(:project)
    should assign_to(:story)
    should assign_to(:task)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :story_id => 1, :project_id => @project.id
    end
    
    should assign_to(:project)
    should assign_to(:story)
    should assign_to(:task)
  end
  
end
