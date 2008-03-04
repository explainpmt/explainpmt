class User < ActiveRecord::Base
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :stories, :include => [:initiative, :iteration, :project, :owner]
  has_many :milestones, :through => :projects
  validates_presence_of :first_name, :last_name, :email, :username, :password
  validates_uniqueness_of :username, :email
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
  
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

  def self.authenticate(username, password)
    find_by_username_and_password(username, password)
  end
  
end
