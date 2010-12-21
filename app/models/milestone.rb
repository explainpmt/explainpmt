class Milestone < ActiveRecord::Base
  belongs_to  :project
  
  validates_presence_of :date
  validates_length_of :name, :in => 1..100
  
  scope :future, lambda{ where("milestones.date > ?", Date.today) }
  scope :recent, lambda{ where("milestones.date < ? and milestones.date > ?", Date.today, Date.today - 15) }
  scope :past, lambda{ where("milestones.date < ?", Date.today) }
end
