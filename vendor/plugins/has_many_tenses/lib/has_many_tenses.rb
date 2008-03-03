# HasManyTenses
module RailsJitsu
  module HasManyTenses #:nodoc:

    def self.included(base)
      base.cattr_accessor :recency
      base.cattr_accessor :compare_to
      base.extend ClassMethods
    end

    module ClassMethods
      
      def has_many_tenses(options = {})
        self.recency = 15.minutes.ago
        if options.is_a?(Hash)
          self.recency = options[:recency] if options[:recency].class == Time
          self.compare_to = options[:compare_to] || :created_at
        end
        include RailsJitsu::HasManyTenses::InstanceMethods
      end
    end
    
    # This module contains class methods
    module SingletonMethods
      def future
        @future ||= find(:all, :conditions => ["#{self.compare_to.to_s} >= ?", Time.now])
      end

      def recent
        @recent ||= find(:all, :conditions => ["#{self.compare_to.to_s} BETWEEN ? and ?", self.recency, Time.now])
      end

      def past
        @past ||= find(:all, :conditions => ["#{self.compare_to.to_s} < ?", Time.now])
      end
    end
    
    # This module contains instance methods
    module InstanceMethods
      def future?
        Time.parse(read_attribute(self.compare_to).to_s) > Time.now
      end

      def recent?
        Time.parse(read_attribute(self.compare_to).to_s).between?(self.recency, Time.now)
      end

      def past?
        Time.parse(read_attribute(self.compare_to).to_s) < Time.now
      end
    end
  end
end
