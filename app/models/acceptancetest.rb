class Acceptancetest < ActiveRecord::Base
  belongs_to :project
  belongs_to :story
  validates_presence_of :name
  validates_length_of :name, :maximum => 255
end