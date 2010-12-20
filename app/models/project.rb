require 'story_point_calc'

class Project < ActiveRecord::Base
  has_many :acceptance_tests, :dependent => :destroy
  has_many :initiatives, :dependent => :destroy
  has_many :iterations, :dependent => :destroy  
  has_many :milestones, :dependent => :destroy  
  has_many :project_memberships, :dependent => :destroy
  has_many :releases, :dependent => :destroy  
  has_many :stories, :extend => StoryPointCalc, :dependent => :destroy  
  has_many :tasks, :through => :stories
  has_many :users, :through => :project_memberships
  
  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 100 }
  validates_numericality_of  :planned_iterations, :only_integer => true, :greater_than => 0, 
    :allow_nil => true, :message => "must be a positive number"
    
  def current_velocity
    return 0 if self.iterations.past.size == 0
    points_completed_for_velocity/self.iterations.past.size
  end

  def points_completed_for_velocity
    points_to_subtract = self.iterations.current.first ? self.iterations.current.first.stories.points_completed : 0
    self.stories.points_completed - points_to_subtract
  end

  def points_not_completed_for_velocity
    points_to_add = self.iterations.current.first ? self.iterations.current.first.stories.points_completed : 0
    self.stories.points_remaining + points_to_add
  end

  def users_available_for_addition
    User.order('last_name ASC, first_name ASC').all - self.users
  end
end