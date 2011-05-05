class Milestone < ActiveRecord::Base
  belongs_to  :project
  
  validates_presence_of :date
  validates_length_of :name, :in => 1..100
  
  scope :future, lambda{ where(:date => Date.today) }
  scope :recent, lambda{ where(:date => ((Date.today - 15)..Date.today)) }
  scope :past, lambda{ where("milestones.date < ?", Date.today) }
end
