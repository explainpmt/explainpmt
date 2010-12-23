require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  
  context "A new project" do
    setup do
      @project = Project.new
    end
    
    should have_many(:acceptance_tests)
    should have_many(:initiatives)
    should have_many(:iterations)
    should have_many(:milestones)
    should have_many(:project_memberships)
    should have_many(:releases)
    should have_many(:stories)
    should have_many(:tasks).through(:stories)
    should have_many(:users).through(:project_memberships)
  end
  
end
