require 'story_point_calc'

class Iteration < ActiveRecord::Base
  belongs_to  :project
  has_many :stories, :extend => StoryPointCalc, :dependent => :nullify
  
  validates_inclusion_of :length, :in => 1..99, :message => 'must be a number between 1 and 99'
  validates_inclusion_of :budget, :in => 1..999, :allow_nil => true,
                         :message => 'must be a number between 1 and 999 (or blank)'
  validates_length_of :name, :in => 1..100
  validates_uniqueness_of :name, :scope => :project_id
  validates_presence_of :start_date
  validate :ensure_no_overlap
  
  scope :with_stop_date, select("date_add(iterations.start_date, INTERVAL iterations.length DAY) as 'stop_date', iterations.*")
  scope :future, where("iterations.start_date > CURDATE()")
  scope :past, with_stop_date.where("date_add(iterations.start_date, INTERVAL iterations.length DAY) < CURDATE()")  
  scope :current, where("iterations.start_date <= CURDATE() and date_add(iterations.start_date, INTERVAL iterations.length DAY) > CURDATE()")
  scope :previous, past.with_stop_date.order('iterations.stop_date DESC').limit(1)
  scope :next, future.order("iterations.start_date ASC").limit(1)

  def available_resources
    (budget || 0) - stories.points_total
  end

  def points_by_user
    stories.inject(Hash.new(0)){|hsh, story| (hsh[story.user_id] += story.points) && hsh}
  end

  def stop_date
    start_date + length - 1
  end

  protected

  def ensure_no_overlap
    return unless project
    project.iterations.each { |iteration|
        errors.add(:start_date, "causes an overlap with #{iteration.length}-day iteration starting on " +
                   "#{iteration.start_date.strftime('%m/%d/%Y')}.") unless id==iteration.id or (stop_date<iteration.start_date or start_date>iteration.stop_date)
    }
  end
end
