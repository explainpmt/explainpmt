require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  
  context "A new task" do
    setup do
      @task = Task.new
    end
    
    should belong_to(:story)
    should belong_to(:owner)
    
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name).scoped_to(:story_id)
  end
  
end
