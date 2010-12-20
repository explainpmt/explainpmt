require 'story_point_calc'

class Release < ActiveRecord::Base
  belongs_to :project
  has_many :stories, :extend => StoryPointCalc, :dependent => :nullify
  
  validates_length_of :name, :in => 1..255
  validates_uniqueness_of :name, :scope => :project_id
end
