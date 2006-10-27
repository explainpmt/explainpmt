=begin License
  eXPlain Project Management Tool
  Copyright (C) 2005  John Wilger <johnwilger@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=end LICENSE

# Story is the basic planning unit of the eXPlainPMT system (as in the eXtreme
# Programming methodology). Story cards are defined and estimated and then
# assigned to an Iteration to schedule them for completion.
#
# Story has the following associations:
#   belongs_to :project
#   belongs_to :iteration
#   belongs_to :owner, :class_name => 'User'
#
# And the following data validations:
#   validates_presence_of :title, :project, :status
#   validates_inclusion_of :points, :in => 1..99, :allow_nil => true
#   validates_uniqueness_of :scid, :scope => 'project_id'
#
# As well as the following aggregations:
#   composed_of :status, :mapping => %w(status order)
#   composed_of :priority, :mapping => %w(priority order)
#   composed_of :risk, :mapping => %w(risk order)
#
class Story < ActiveRecord::Base
  belongs_to :project
  belongs_to :iteration
  belongs_to :owner, :class_name => 'User'

  # The collection of defined Status objects
  Statuses = []

  # The collection of defined Priority objects
  Priorities = []

  # The collection of defined Risk objects
  Risks = []

  validates_presence_of :title, :project, :status

  # A range representing valid values for the #points attribute
  POINT_RANGE = 1..9
  
  validates_inclusion_of :points, :in => POINT_RANGE, :allow_nil => true,
    :message => "must be a number between #{POINT_RANGE.first} and " +
                "#{POINT_RANGE.last}"
  validates_uniqueness_of :scid, :scope => 'project_id'
  
  composed_of :status, :mapping => %w(status order)
  composed_of :priority, :mapping => %w(priority order)
  composed_of :risk, :mapping => %w(risk order)

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
    
    # Returns +true+ if the status represents a story where the work is
    # complete.
    def complete?
      @complete
    end

    # Returns +true+ if the status represents a story that is closed, meaning no
    # further work is required.
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
  end

  class Priority < RankedValue
    class << self
      def new(order)
        super(order,Priorities)
      end
    end

    Priorities << High = create(1, 'High')
    Priorities << MedHigh = create(2, 'Med-High')
    Priorities << Medium = create(3, 'Medium')
    Priorities << MedLow = create(4, 'Med-Low')
    Priorities << Low = create(5, 'Low')
    Priorities << NA = create(6,'')
  end

  class Risk < RankedValue
    class << self
      def new(order)
        super(order,Risks)
      end
    end

    Risks << High = create(1, 'High')
    Risks << Medium = create(2, 'Medium')
    Risks << Low = create(3, 'Low')
    Risks << NA = create(4, '')
  end

  # When determining the current value for an aggregation, we need to use the
  # "id" of the item in the HTML forms, but the aggregate methods return the
  # actual object. By calling this method, the aggregate methods are overridden
  # to provide this id value, i.e.:
  #
  #   story = Story.new
  #   story.return_ids_for_aggregations
  #   story.status                        => 1
  #   story.priority                      => 6
  #   story.risk                          => 4
  def return_ids_for_aggregations
    self.instance_eval <<-EOF
      def status
        read_attribute('status')
      end
      def priority
        read_attribute('priority')
      end
      def risk
        read_attribute('risk')
      end
    EOF
  end

  protected

  def validate
    self.iteration = nil if self.status == Status::Cancelled
    validate_has_iteration_only_if_defined
    validate_is_new_or_cancelled_if_not_defined
  end

  # The after_initialize callback is used to set the default values for #status,
  # #priority and #risk.
  def after_initialize
    self.status = Status::New unless self.status
    self.priority = Priority::NA unless self.priority
    self.risk = Risk::NA unless self.risk
  end

  def before_create
    if last_story = self.project.stories.find_first(nil, 'scid DESC')
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
      errors.add(:status,
        "can only be New or Cancelled unless all fields " +
        "are complete")
    end
  end

  def validate_has_iteration_only_if_defined
    unless is_defined?
      errors.add(:iteration,
        "can only be specified for defined stories") if
        self.has_iteration?
    end
  end

  def is_defined?
    self.priority != Priority::NA and self.risk != Risk::NA and self.points? and
    self.description?
  end

  def before_save_reset_status
    if self.status == Status::Defined and self.has_owner?
      self.status = Status::InProgress
    end

    if self.status == Status::New and self.priority != Priority::NA and
      self.risk != Risk::NA and self.points? and self.description?
      self.status = Status::Defined
    end
  end
end
