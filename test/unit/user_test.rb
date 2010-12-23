require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "A new user" do
    setup do
      @user = User.new
    end
    
    # should have_many(:milestones).through(:projects)
    should have_many(:project_memberships)
    should have_many(:projects).through(:project_memberships)
    should have_many(:stories)
    should have_many(:tasks)
    
    should validate_presence_of(:first_name)
    should validate_presence_of(:last_name)
  end
  
  context "A user instance" do
    setup do
      @user = users(:david)
    end
    
    should "return its full name" do
      assert_equal @user.full_name, "#{@user.first_name} #{@user.last_name}"
    end
  end
  
end
