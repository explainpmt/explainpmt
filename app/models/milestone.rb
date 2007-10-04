class Milestone < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :name, :date
  validates_length_of :name, :maximum => 100
end

