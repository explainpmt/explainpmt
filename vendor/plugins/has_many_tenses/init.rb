# Include hook code here
require 'has_many_tenses'
ActiveRecord::Base.send(:include, RailsJitsu::HasManyTenses)
