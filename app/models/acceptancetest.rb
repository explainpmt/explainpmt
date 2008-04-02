class Acceptancetest < ActiveRecord::Base
  belongs_to :project
  belongs_to :story
  validates_presence_of :name
  validates_length_of :name, :maximum => 255

  def clone!
    acceptancetest = self.clone
    acceptancetest.name = "Clone:" + acceptancetest.name
    acceptancetest.save!
  end

  def self.assign_many_to_story(story, acceptancetests)
    successes, failures = [], []
    acceptancetests.each do |acceptancetest|
      acceptancetest.story = story
      if acceptancetest.save
        successes << "Acceptance Tests #{acceptancetest.name} has been moved."
      else
        failures << "Acceptance Tests #{acceptancetest.name} could not be moved."
      end
    end
    {:successes => successes, :failures => failures}
  end

end