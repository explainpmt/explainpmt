class StoryCard < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  Statuses   = { 1 => 'New',
                 2 => 'In Progress',
                 3 => 'Rejected',
                 4 => 'Blocked',
                 5 => 'Complete',
                 6 => 'Accepted',
                 7 => 'Cancelled' }
  
  Risks      = { 3 => 'High',
                 2 => 'Medium',
                 1 => 'Low',
                 0 => '' }

  # A range representing valid values for the #points attribute
  POINT_RANGE = 1..9

  validates_presence_of :name, :status, :project
  validates_length_of :name, :maximum => 100
  validates_uniqueness_of :scid, :scope => 'project_id'
  validates_numericality_of :points, :only_integer => true, :allow_nil => true

  def after_initialize
    self.status = 1 unless self.status
    self.risk = 0 unless self.risk
  end
  
  def before_create
    if self.project
      if last_story = self.project.story_cards.find_first(nil, 'scid DESC')
        self.scid = last_story.scid + 1
      else
        self.scid = 1
      end
    end
  end
end