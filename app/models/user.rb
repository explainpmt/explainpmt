class User < ActiveRecord::Base
  
  
  class << self
    def authenticate( login, password )
      unless login.nil? || password.nil?
        find :first, :conditions => [ 'login = ? AND password = ?',
          login, password  ]
      end
    end
  end
end
