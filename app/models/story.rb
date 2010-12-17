class Story < ActiveRecord::Base
  include Position
  
  belongs_to :project
  belongs_to :iteration
  belongs_to :initiative
  belongs_to :release
  belongs_to :creator, :class_name => 'User'
  belongs_to :updater, :class_name => 'User'
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  
  has_many :tasks, :dependent => :destroy
  has_many :acceptance_tests, :dependent => :destroy
  
  has_many  :audits,  :as => :auditable
  
  ## CHANGED => included Position module for now to limit dependence on outdated plugins.
  # acts_as_list :scope => :project_id

  Statuses = []
  Values = []
  Risks = []

  validates_presence_of :title, :project, :status
  validates_uniqueness_of :scid, :scope => :project_id
  validates_length_of :title, :maximum => 255
  validates_numericality_of :points, :only_integer => true, :greater_than_or_equal_to => 0, :message => "must be a positive integer"
  
  validate :has_iteration_only_if_defined
  validate :is_new_or_cancelled_if_not_defined
  
  before_validation { |x| x.iteration = nil if x.status == Status::Cancelled }
  
  before_create :set_scid
  before_save   :before_save_reset_status
  after_update  :audit_story

  composed_of :status, :mapping => %w(status order), :class_name => 'Story::Status'
  composed_of :value, :mapping => %w(value order), :class_name => 'Story::Value'
  composed_of :risk, :mapping => %w(risk order), :class_name => 'Story::Risk'

  class RankedValue
    class InvalidOrder < Exception;end

    include Comparable

    attr_reader :order, :name

    class << self
      alias_method :create, :new
      def new(order, collection = [])
        if order.nil?
          return nil
        elsif obj = collection.select{|o| o.order == order}.first
          return obj
        else
          raise InvalidOrder
        end
      end
    end

    def initialize(order,name)
      @order = order
      @name = name
    end

    def <=>(other)
      self.order <=> other.order
    end

    def to_s
      @name
    end
  end

  class Status < RankedValue
    class << self
      def new(order)
        super(order, Statuses)
      end
    end

    def initialize(order, name, complete = false, closed = false)
      super(order,name)
      @complete = complete
      @closed = closed
    end

    def complete?
      @complete
    end

    def closed?
      @closed
    end

    Statuses << New = create(1, 'New')
    Statuses << Defined = create(2, 'Defined')
    Statuses << InProgress = create(3, 'In Progress')
    Statuses << Rejected = create(4, 'Rejected')
    Statuses << Blocked = create(5, 'Blocked')
    Statuses << Complete = create(6, 'Complete', true)
    Statuses << Accepted = create(7, 'Accepted', true, true)
    Statuses << Cancelled = create(8, 'Cancelled', false, true)
    Statuses << Obstacle = create(9, 'Obstacle')

  end

  class Value < RankedValue
    class << self
      def new(order)
        super(order,Values)
      end
    end

    Values << High = create(1, 'High')
    Values << MedHigh = create(2, 'Med-High')
    Values << Medium = create(3, 'Medium')
    Values << MedLow = create(4, 'Med-Low')
    Values << Low = create(5, 'Low')
    Values << NA = create(6,'')
  end

  class Risk < RankedValue
    class << self
      def new(order)
        super(order,Risks)
      end
    end

    Risks << High = create(1, 'High')
    Risks << Normal = create(2, 'Normal')
    Risks << Low = create(3, 'Low')
    Risks << NA = create(4,'')
  end

  def return_ids_for_aggregations
    self.instance_eval <<-EOF
      def status
        read_attribute('status')
      end
      def value
        read_attribute('value')
      end
      def risk
        read_attribute('risk')
      end
    EOF
  end

  def audit_story
    Audit.create!(self, :update)
  end

  def assign_to(new_owner)
    update_attribute(:user_id, new_owner.id)
  end

  def release_ownership
    update_attribute(:user_id, nil)
  end

  def clone!
    story = self.clone
    story.status = status
    story.value = valule
    story.risk = risk
    story.title = "Clone: #{title}"
    story.scid = nil
    story.save!
  end

  def self.assign_many_to_iteration(iteration, stories)
    successes, failures = [], []
    stories.each do |s|
      s.iteration = iteration
      if s.save
        successes << "SC#{s.scid} has been moved."
      else
        failures << "SC#{s.scid} could not be moved. (make sure it is defined)"
      end
    end
    { :successes => successes, :failures => failures }
  end
  
  def self.assign_many_to_release(release, stories)
    successes, failures = [], []
    stories.each do |s|
      s.release = release
      if s.save
        successes << "SC#{s.scid} has been moved."
      else
        failures << "SC#{s.scid} could not be moved."
      end
    end
    { :successes => successes, :failures => failures }
  end

  protected

  def after_initialize
    self.status = Status::New unless self.status
    self.value = Story::Value::NA unless self.value
    self.risk = Story::Risk::Normal unless self.risk
  end

  def set_scid
    if last_story = project.stories.order('scid DESC').first
      self.scid = last_story.scid + 1
    else
      self.scid = 1
    end
  end

  private
  ## TODO => don't know if this could be moved into validates_inclusion_of or something similar?
  def is_new_or_cancelled_if_not_defined
    unless is_defined? or [Status::New,Status::Cancelled].include?(self.status)
      errors[:status] << "can only be New or Cancelled unless all fields are complete"
    end
  end
  
  ## TODO => could this be written more readable?
  def has_iteration_only_if_defined
    unless is_defined?
      errors[:iteration] << "can only be specified for defined stories" if iteration
    end
  end

  def is_defined?
    self.value != Value::NA and self.points
  end

  def before_save_reset_status
    self.owner = nil if self.iteration.nil?
    self.status = Status::InProgress if status == Status::Defined and owner
    self.status = Status::Defined if status == Status::New and is_defined?
  end
  
end
