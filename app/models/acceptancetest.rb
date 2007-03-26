class Acceptancetest < ActiveRecord::Base
  belongs_to :project
  belongs_to :story
  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  
  def self.find_all_acceptance_tests(project_id)
   self.find(:all, :include => [{:story => :iteration}], :conditions => [ "acceptancetests.project_id = (?)", project_id])
  end
end