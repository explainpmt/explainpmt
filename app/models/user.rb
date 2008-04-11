require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :stories, :include => [:initiative, :iteration, :project, :owner]
  has_many :milestones, :through => :projects
  validates_presence_of :first_name, :last_name, :email, :username
  validates_uniqueness_of :username, :email
  validates_confirmation_of :set_password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
  before_save :encrypt_password

  attr_accessor :set_password, :set_password_confirmation

  def stories_for(project)
    self.stories.find(:all, :conditions => "stories.project_id = #{project.id}")
  end

  def tasks_for(project)
    Task.find_by_sql ["SELECT * FROM tasks where user_id = #{id} AND story_id in (select id from stories where project_id = ? AND status not in (7,8))", project.id]
  end

  def tasks
    Task.find_by_sql "SELECT * FROM tasks where user_id = #{id} AND story_id in (select id from stories where status not in (7,8))"
  end

  def full_name(last_first = false)
    last_first ? "#{last_name}, #{first_name}" : "#{first_name} #{last_name}"
  end

  def self.authenticate(uname, pword)
    u = find_by_username(uname) # need to get the salt
    u && u.authenticated?(pword) ? u : nil
  end

  def self.encrypt(pword, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{pword}--")
  end

  def encrypt(pword)
    self.class.encrypt(pword, salt)
  end

  def authenticated?(pword)
    password == encrypt(pword)
  end

  protected
  def encrypt_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") if new_record?
    self.password = encrypt(set_password) if !set_password.blank?
  end
end
