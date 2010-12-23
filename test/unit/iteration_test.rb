require 'test_helper'

class IterationTest < ActiveSupport::TestCase
  
  context "A new iteration" do
    setup do
      @iteration = Iteration.new
    end
    
    should belong_to(:project)
    should have_many(:stories)
    should validate_presence_of(:start_date)
    should validate_uniqueness_of(:name).scoped_to(:project_id)
  end
  
end
