ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  ALL_FIXTURES = [ :iterations,
                   :milestones,
                   :projects_users,
                   :projects,
                   :stories,
                   :users,
                   :sub_projects,
                   :tasks,
                   :acceptancetests ]
    
  class << self
    def test_required_attributes( klass, *attributes )
      attributes.each do |attribute|
        self.class_eval %Q{
        def test_#{attribute}_is_required
        object = #{klass}.new
        assert !object.valid?
        assert object.errors.on( :#{attribute} )
        assert object.errors.on( :#{attribute} ).to_a.
        include?( "can't be blank" )
        end
        }
      end
    end

    def test_unique_attributes( klass, existing_id, *attributes )
      attributes.each do |attribute|
        self.class_eval %Q{
        def test_#{attribute}_must_be_unique
        existing = #{klass}.find #{existing_id}
        object = #{klass}.new
        object.#{attribute} = existing.#{attribute}
        assert !object.valid?
        assert object.errors.on( :#{attribute} )
        assert object.errors.on( :#{attribute} ).to_a.
        include?( 'has already been taken' )
        end
        }
      end
    end
  end
end
