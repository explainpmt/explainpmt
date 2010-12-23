require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  
  context "A new story" do
    setup do
      @story = Story.new
    end
    
    should belong_to(:project)
    should belong_to(:iteration)
    should belong_to(:initiative)
    should belong_to(:release)
    should belong_to(:creator)
    should belong_to(:updater)
    should belong_to(:owner)
    
    should have_many(:tasks)
    should have_many(:acceptance_tests)
    should have_many(:audits)
    
    should validate_presence_of(:title)
    should validate_presence_of(:project)
    should validate_presence_of(:status)
  end
  
end
