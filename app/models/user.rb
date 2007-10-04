class User < ActiveRecord::Base
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :stories
  has_many :milestones, :through => :projects
  validates_presence_of :first_name, :last_name, :email, :username, :password
  validates_uniqueness_of :username, :email
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
  
  def find_all_stories_by_project(project_id)
    Story.find(:all, :include => [:initiative, :iteration, :project, :owner], :conditions => "stories.project_id = #{project_id} and stories.user_id = #{id}")
  end

  def full_name(last_first = false)
    last_first ? "#{last_name}, #{first_name}" : "#{first_name} #{last_name}"
  end

  def self.authenticate(username, password)
    find_by_username_and_password(username, password)
  end
  
end
