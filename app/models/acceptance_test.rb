class AcceptanceTest < ActiveRecord::Base
  belongs_to  :project
  belongs_to  :story

  validates_length_of :name, :in => 1..255
  scope :with_details, includes({:story => :iteration})
  
  def clone!
    self.clone.tap do |ac|
      ac.name = "Clone: #{name}"
      ac.save!
    end
  end
  
  def self.assign_many_to_story(story, acceptance_tests)
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
