# ===Scruffy Formatters
#
# Author:: Brasten Sager
# Date:: August 16th, 2006
#
# Formatters are used to format the values displayed on the y-axis by
# setting graph.value_formatter.
#
# Example:
#
#   graph.value_formatter = Scruffy::Formatters::Currency.new(:precision => 0)
#
module Scruffy::Formatters
  
  # == Scruffy::Formatters::Base
  #
  # Author:: Brasten Sager
  # Date:: August 16th, 2006
  #
  # Formatters are used to format the values displayed on the y-axis by
  # setting graph.value_formatter.
  class Base
    
    # Called by the value marker component.  Routes the format call
    # to one of a couple possible methods.
    #
    # If the formatter defines a #format method, the returned value is used
    # as the value.  If the formatter defines a #format! method, the value passed is
    # expected to be modified, and is used as the value.  (This may not actually work,
    # in hindsight.)
    def route_format(target, idx, options = {})
      args = [target, idx, options]
      if respond_to?(:format)
        send :format, *args[0...self.method(:format).arity]
      elsif respond_to?(:format!)
        send :format!, *args[0...self.method(:format!).arity]
        target
      else
        raise NameError, "Formatter subclass must container either a format() method or format!() method."
      end
    end

    protected
      def number_with_precision(number, precision=3)  #:nodoc:
        sprintf("%01.#{precision}f", number)
      end
  end
  
  # Allows you to pass in a Proc for use as a formatter.
  #
  # Use:
  #
  # graph.value_formatter = Scruffy::Formatters::Custom.new { |value, idx, options| "Displays Returned Value" }
  class Custom < Base
    attr_reader :proc
    
    def initialize(&block)
      self.proc = block
    end
    
    def format(target, idx, options)
      proc.call(target, idx, options)
    end
  end
  
  
  
  # Default number formatter.
  # Limits precision, beautifies numbers.
  class Number < Base
    attr_accessor :precision, :separator, :delimiter, :precision_limit
    
    # Returns a new Number formatter.
    #
    # Options:
    # precision:: precision to use for value.  Can be set to an integer, :none or :auto.
    #             :auto will use whatever precision is necessary to portray all the numerical
    #             information, up to :precision_limit.
    #
    #             Example:  [100.1, 100.44, 200.323] will result in [100.100, 100.440, 200.323]
    #
    # separator:: decimal separator.  Defaults to '.'
    # delimiter:: delimiter character.  Defaults to ','
    # precision_limit:: upper limit for auto precision.
    def initialize(options = {})
      @precision        = options[:precision] || :none
      @separator        = options[:separator] || '.'
      @delimiter        = options[:delimiter] || ','
      @precision_limit  = options[:precision_limit] || 4
    end
    
    # Formats the value.
    def format(target, idx, options)
      my_precision = @precision
      
      if @precision == :auto
        my_precision = options[:all_values].inject(0) do |highest, current|
          cur = current.to_f.to_s.split(".").last.size
          cur > highest ? cur : highest
        end
      
        my_precision = @precision_limit if my_precision > @precision_limit
      elsif @precision == :none
        my_precision = 0
      end
      
      my_separator = @separator
      my_separator = "" unless my_precision > 0
      begin
        parts = number_with_precision(target, my_precision).split('.')
        
        number = parts[0].to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{@delimiter}") + my_separator + parts[1].to_s
        number
      rescue StandardError => e
        target
      end
    end
  end
  
  # Currency formatter.
  #
  # Provides formatting for currencies.
  class Currency < Base
    
    # Returns a new Currency class.
    #
    # Options:
    # precision:: precision of value
    # unit:: Defaults to '$'
    # separator:: Defaults to '.'
    # delimiter:: Defaults to ','
    # negative_color:: Color of value marker for negative values.  Defaults to 'red'
    # special_negatives:: If set to true, parenthesizes negative numbers.  ie:  -$150.50 becomes ($150.50).
    #                     Defaults to false.
    def initialize(options = {})
      @precision        = options[:precision] || 2
      @unit             = options[:unit] || '$'
      @separator        = options[:separator] || '.'
      @delimiter        = options[:delimiter] || ','
      @negative_color   = options[:negative_color] || 'red'
      @special_negatives = options[:special_negatives] || false
    end
    
    # Formats value marker.
    def format(target, idx, options)
      @separator = "" unless @precision > 0
      begin
        parts = number_with_precision(target, @precision).split('.')
        if @special_negatives && (target.to_f < 0)
          number = "(" + @unit + parts[0].to_i.abs.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{@delimiter}") + @separator + parts[1].to_s + ")"
        else
          number = @unit + parts[0].to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{@delimiter}") + @separator + parts[1].to_s
        end
        if (target.to_f < 0) && @negative_color
          options[:marker_color_override] = @negative_color
        end
        number
      rescue
        target
      end
    end
  end
  
  # Percentage formatter.
  #
  # Provides formatting for percentages.  
  class Percentage < Base
    
    # Returns new Percentage formatter.
    #
    # Options:
    # precision:: Defaults to 3.
    # separator:: Defaults to '.'
    def initialize(options = {})
      @precision    = options[:precision] || 3
      @separator    = options[:separator] || '.'
    end
    
    # Formats percentages.
    def format(target)
      begin
        number = number_with_precision(target, @precision)
        parts = number.split('.')
        if parts.at(1).nil?
          parts[0] + "%"
        else
          parts[0] + @separator + parts[1].to_s + "%"
        end
      rescue
        target
      end
    end
  end

end