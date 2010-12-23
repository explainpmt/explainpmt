ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'flexmock/test_unit'
require 'authlogic/test_case'

class ActiveSupport::TestCase
  setup :activate_authlogic
  
  # This extension prints to the log before each test.  Makes it easier to find the test you're looking for when looking through a long test log.
  setup :log_test
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  def login_as(user)
    UserSession.create(users(user))
  end
  
  def valid_user_params(opts={})
    opts.reverse_merge({ 
      :first_name => "Bob", 
      :last_name => "Lawblaw", 
      :email => "bob.lawblaw@test.invalid.bla", 
      :login => "boblawblaw", 
      :password => "testing", 
      :password_confirmation => "testing"
    })
  end
  
  private
  def log_test
    puts "\n\n>> Starting #{self.name}\n#{'-' * 130}"
  end
end
