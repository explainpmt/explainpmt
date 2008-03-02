class Story < ActiveRecord::Base
  belongs_to :project
  belongs_to :iteration
  belongs_to :initiative
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  has_many :tasks, :dependent => :destroy
  has_many :acceptancetests, :dependent => :destroy
  acts_as_list :scope => :project_id

  Statuses = []
  Values = []
  Risks = []

  validates_presence_of :title, :project, :status

  validates_uniqueness_of :scid, :scope => 'project_id'
  
  validates_length_of :title, :maximum => 255
  
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

  @@open_status_sql = Statuses.select { |s| !s.closed? }.collect { |s| s.order }.join(',')
  def self.with_open(&block)
    with_scope(:find => {:conditions => "not status in (#{@@open_status_sql})"}) do
      yield
    end
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
  
  def audits
    Audit.find(:all, :conditions => ["project_id = #{project_id} AND audited_object_id = #{id} AND object = 'Story'"], :order => "created_at DESC")
  end
  
  def audit_story
    if !self.new_record?
      story = Story.find(self.id)
      audit = Audit.new
      audit.audited_object_id = self.id
      audit.object = "Story"
      audit.project_id = self.project_id
      audit.user = User.find(self.updater_id).full_name
       self.attributes.each do |key, value|
        if story.attributes[key] != value && key != "updater_id"
            audit.before = "" unless audit.before
            audit.after = "" unless audit.after
            audit.before << key + "[" + story.attributes[key].to_s + "]\n"
            audit.after << key + "[" + value.to_s + "]\n"
        end
       end
      audit.save
    end
  end

  protected

  def validate
    self.iteration = nil if self.status == Status::Cancelled
    validate_has_iteration_only_if_defined
    validate_is_new_or_cancelled_if_not_defined
    validate_points
  end

  def after_initialize
    self.status = Status::New unless self.status
    self.value = Story::Value::NA unless self.value
    self.risk = Story::Risk::Normal unless self.risk
  end

  def before_create
    if last_story = project.stories.find( :first, :order => 'scid DESC' )
      self.scid = last_story.scid + 1
    else
      self.scid = 1
    end
  end

  def before_save
    self.owner = nil if self.iteration.nil?
    before_save_reset_status
  end

  private

  def validate_is_new_or_cancelled_if_not_defined
    unless is_defined? or [Status::New,Status::Cancelled].include?(self.status)
      errors.add(:status, "can only be New or Cancelled unless all fields are complete")
    end
  end

  def validate_has_iteration_only_if_defined
    unless is_defined?
      errors.add(:iteration, "can only be specified for defined stories") if iteration
    end
  end

  def validate_points
    errors.add(:points, "must be a positive integer") if self.points and self.points < 1
  end
  
  def is_defined?
    self.value != Value::NA and self.points?
  end

  def before_save_reset_status
    self.status = Status::InProgress if status == Status::Defined and owner
    self.status = Status::Defined if status == Status::New and is_defined?
  end
end
