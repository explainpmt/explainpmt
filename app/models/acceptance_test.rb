class AcceptanceTest < ActiveRecord::Base
  belongs_to  :project
  belongs_to  :story
  
  validates_presence_of :name
  validates_length_of :name,  :maximum => 255
  
  def clone!
    acceptance_test = self.clone
    acceptance_test.name = "Clone: #{name}"
    acceptance_test.save!
    acceptance_test
  end
  
  def self.assign_many_to_story(stor, acceptance_tests)
    successes, failures = [], []
    acceptance_tests.each do |acceptance_test|
      acceptance_test.story = story
      if acceptance_test.save
        successes << "Acceptance Tests #{acceptance_test.name} has been moved."
      else
        failures << "Acceptance Tests #{acceptance_test.name} could not be moved."
      end
    end
    { :successes => successes, :failures => failures }
  end
  
end
