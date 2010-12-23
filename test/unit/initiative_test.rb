require 'test_helper'

class InitiativeTest < ActiveSupport::TestCase
  
  context "A new initiative" do
    setup do
      @initiative = Initiative.new
    end
    
    should belong_to(:project)
    should have_many(:stories)
    should validate_uniqueness_of(:name).scoped_to(:project_id)
  end
  
end
