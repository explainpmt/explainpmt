require 'test_helper'

class MilestoneTest < ActiveSupport::TestCase
  
  context "A new milestone" do
    setup do
      @milestone = Milestone.new
    end
    
    should belong_to(:project)
    should validate_presence_of(:date)
  end
  
end
