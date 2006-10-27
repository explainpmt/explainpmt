class User < ActiveRecord::Base
  validates_presence_of :name, :login, :email, :password
  validates_uniqueness_of :login
  validates_confirmation_of :password
  before_destroy :do_not_destroy_last_admin
  class << self
    def authenticate( login, password )
      unless login.nil? || password.nil?
        find :first, :conditions => [ 'login = ? AND password = ?',
          login, password  ]
      end
    end
  end

  def do_not_destroy_last_admin
    if self.admin and User.count( [ 'admin = ?', true ] ) < 2
      return false
    end
  end
end
