require 'position'
class Story < ActiveRecord::Base
  include Position
  include AttributeMapper
  
  map_attribute :status, :to => {:new => 1, :defined => 2, :in_progress => 3, 
    :rejected => 4, :blocked => 5, :complete => 6, :accepted => 7, :cancelled => 8, :obstacle => 9}
    
  map_attribute :value, :to => {:high => 1, :med_high => 2, :medium => 3, :med_low => 4, :low => 5, :na => 6}
  map_attribute :risk, :to => {:high => 1, :normal => 2, :low => 3, :na => 4}
  
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

  validates_presence_of :title, :project, :status
  validates_uniqueness_of :scid, :scope => :project_id
  validates_length_of :title, :maximum => 255
  validates_numericality_of :points, :only_integer => true, :greater_than_or_equal_to => 0, :message => "must be a positive integer", :if => proc{|x| x.iteration}
  
  scope :with_details, includes(:initiative, :project, :owner, :iteration, :release)
  scope :backlog, where("stories.iteration_id is null")
  scope :cancelled, lambda{ backlog.where("stories.status = ?", Story.statuses[:cancelled]) }
  scope :completed, lambda{ where("stories.status in (?)", [Story.statuses[:complete], Story.statuses[:accepted]]) }
  scope :incomplete, lambda{ where("stories.status not in (?)", [Story.statuses[:complete], Story.statuses[:accepted], Story.statuses[:cancelled]]) }
  scope :not_cancelled, lambda{ where("stories.status <> ?", Story.statuses[:cancelled]) }
  scope :not_estimated_and_not_cancelled, lambda{ not_cancelled.where("stories.points is null") }
  scope :not_cancelled_and_not_assigned_to_an_iteration, lambda{ backlog.not_cancelled }
  scope :last_position, order("position DESC").limit(1)
  scope :last_scid, order("scid DESC").limit(1)  
  scope :for_user, lambda{|user| where("user_id = ?", user.id)}  
  
  before_create :set_scid
  before_save   :before_save_reset_status
  after_update  :audit_story
  
  def complete?
    [:accepted, :complete].include?(self.status)
  end
  
  def closed?
    [:accepted, :complete, :cancelled].include?(self.status)    
  end

  def audit_story
    Audit.create!(self, :update)
  end

  def assign_to!(new_owner)
    update_attribute(:user_id, new_owner.id)
  end

  def release_ownership!
    update_attribute(:user_id, nil)
  end

  def clone!
    self.clone.tap do |ac|
      ac.title = "Clone: #{name}"
      ac.save!
    end
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
    self.status = :new unless self.status
    self.value = :na unless self.value
    self.risk = :normal unless self.risk
  end

  def set_scid
    self.scid = project.stories.last_scid.first.scid + 1 rescue 1
  end

  private

  def before_save_reset_status
    self.iteration = nil if status == :cancelled    
    self.owner = nil if self.iteration.nil?
    self.status = :in_progress if status == :defined and owner
    self.status = :defined if status == :new and self.points
  end
  
end
