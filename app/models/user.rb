class User < ActiveRecord::Base
  acts_as_authentic do |c|
    ## Allow existing users to login with their current passwords which were previously hashed using Sha1
    ## transition will force authlogic to rehash those passwords using Sha512
    c.transition_from_crypto_providers = OldSha1
  end
  cattr_accessor :current_user

  has_many  :milestones, :through => :projects
  has_many  :project_memberships, :dependent => :destroy
  has_many  :projects,  :through => :project_memberships  
  has_many  :stories, :dependent => :nullify
  has_many  :tasks, :dependent => :nullify

  validates_presence_of :first_name, :last_name

  def full_name
    "#{first_name} #{last_name}"
  end
  
end
