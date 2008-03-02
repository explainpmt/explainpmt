class Milestone < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :name, :date
  validates_length_of :name, :maximum => 100
  
  def future?
    date >= Date.today
  end
  
  def recent?
    date.between?(Date.today - 15, Date.today)
  end
  
  def past?
    date < Date.today
  end
end

