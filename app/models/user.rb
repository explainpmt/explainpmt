class User < ActiveRecord::Base
  validates_presence_of :name, :login, :email, :password
  validates_uniqueness_of :login
  validates_confirmation_of :password
  class << self
    def authenticate( login, password )
      unless login.nil? || password.nil?
        find :first, :conditions => [ 'login = ? AND password = ?',
          login, password  ]
      end
    end
  end
end
