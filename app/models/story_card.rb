class StoryCard < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  Statuses   = { 1 => 'New',
                 2 => 'Defined',
                 3 => 'In Progress',
                 4 => 'Rejected',
                 5 => 'Blocked',
                 6 => 'Complete',
                 7 => 'Accepted',
                 8 => 'Cancelled' }

  Priorities = { 5 => 'High',
                 4 => 'Med-High',
                 3 => 'Medium',
                 2 => 'Med-Low',
                 1 => 'Low',
                 0 => '' }
  
  Risks      = { 3 => 'High',
                 2 => 'Medium',
                 1 => 'Low',
                 0 => '' }

  # A range representing valid values for the #points attribute
  POINT_RANGE = 1..9

  validates_presence_of :name, :status, :project
  validates_length_of :name, :maximum => 100
  validates_uniqueness_of :scid, :scope => 'project_id'
  validates_inclusion_of :points, :in => POINT_RANGE, :allow_nil => true,
    :message => "must be a number between #{POINT_RANGE.first} and " +
                "#{POINT_RANGE.last}"

  def after_initialize
    self.status = 1 unless self.status
    self.priority = 0 unless self.priority
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