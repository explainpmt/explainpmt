require 'test_helper'

class ReleaseTest < ActiveSupport::TestCase
  
  context "A new release" do
    setup do
      @release = Release.new
    end
    
    should belong_to(:project)
    should have_many(:stories)
    
    should validate_uniqueness_of(:name).scoped_to(:project_id)
  end
  
end
