class Iteration < ActiveRecord::Base
  belongs_to :project
  validates_inclusion_of :length, :in => 1..99,
                         :message => 'must be a number between 1 and 99'
  validates_inclusion_of :budget, :in => 1..999, :allow_nil => true,
                         :message => 'must be a number between 1 and 999 ' +
                                     '(or blank)'
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id
  validates_presence_of :start_date
  has_many :stories, :include => [:initiative, :project, :owner, :iteration], :dependent => :nullify do

    def total_points
      self.inject(0){ |res,s| res + s.points }
    end

    def completed_points
      completed_stories = self.select { |s| s.status.complete? }
      completed_stories.inject(0) { |res,s| res + s.points }
    end

    def remaining_points
      total_points - completed_points
    end
  end

  def stop_date
    start_date + length - 1
  end

  def remaining_resources
    (budget || 0) - stories.total_points
  end

  def points_by_user
    stories.inject(Hash.new(0)){|hsh, story| (hsh[story.user_id] += story.points) && hsh}
  end
  
  def current?
    Time.now.at_midnight.between?(start_date.to_time, stop_date.to_time)
  end

  def future?
    start_date.to_time >= Time.now.tomorrow.at_midnight
  end

  def past?
    stop_date.to_time < Time.now.at_midnight
  end
  
  protected

  def validate
    ensure_no_overlap
  end

  def ensure_no_overlap
    project.iterations.each { |iteration|
        errors.add(:start_date, "causes an overlap with #{iteration.length}-day iteration starting on " +
                   "#{iteration.start_date.strftime('%m/%d/%Y')}.") unless id==iteration.id or (stop_date<iteration.start_date or start_date>iteration.stop_date)
    }
  end
end