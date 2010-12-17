class User < ActiveRecord::Base
  acts_as_authentic do |c|
    ## Allow existing users to login with their current passwords which were previously hashed using Sha1
    ## transition will force authlogic to rehash those passwords using Sha512
    c.transition_from_crypto_providers = OldSha1
  end
  cattr_accessor :current_user
  
  has_and_belongs_to_many :projects
  
  has_many :stories, :include => [:initiative, :iteration, :project, :owner]
  has_many :milestones, :through => :projects
  validates_presence_of :first_name, :last_name
  
  def stories_for(project)
    stories.where("project_id=?", project.id)
  end

  def tasks_for(project)
    ## TODO => make 7,8 not hard-coded?
    tasks.where("story_id in (select id from stories where project_id=? and status not in (7,8))", project.id)
  end

  def tasks
    ## TODO => make 7,8 not hard-coded?
    tasks.where("story_id in (select id from stories where status not in (7,8))")
  end

  def full_name(last_first = false)
    last_first ? "#{last_name}, #{first_name}" : "#{first_name} #{last_name}"
  end
  
end
