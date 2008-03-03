class Milestone < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :name, :date
  validates_length_of :name, :maximum => 100
  has_many_tenses :compare_to => :date, :recency => 15.days.ago
end

