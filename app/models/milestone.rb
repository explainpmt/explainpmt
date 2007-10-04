class Milestone < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :name, :date
  validates_length_of :name, :maximum => 100
  
  def future?
    date >= Date.today
  end
  
  def recent?
    date < Date.today && date > Date.today - 15
  end
  
  def past?
    date < Date.today
  end
end

