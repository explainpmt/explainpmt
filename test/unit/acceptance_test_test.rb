require 'test_helper'

class AcceptanceTestTest < ActiveSupport::TestCase
  
  context "A new acceptance test" do
    setup do
      @acceptance_test = AcceptanceTest.new
    end
    
    should belong_to(:project)
    should belong_to(:story)
  end
  
end
