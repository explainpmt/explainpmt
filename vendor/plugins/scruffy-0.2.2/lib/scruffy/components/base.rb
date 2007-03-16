module Scruffy
  module Components
    class Base
      attr_reader :id
      
      # In terms of percentages:  [10, 10] == 10% by 10%
      attr_accessor :position
      attr_accessor :size
      attr_accessor :options
      attr_accessor :visible
      
      def initialize(id, options = {})
        @id = id.to_sym
        @position = options[:position] || [0, 0]
        @size = options[:size] || [100, 100]
        @visible = options[:visible] || true
        @options = options
      end
      
      def render(svg, bounds, options={})
        if @visible
          unless bounds.nil?
            @render_height = bounds[:height]
        
            svg.g(:id => id.to_s, 
                  :transform => "translate(#{bounds.delete(:x)}, #{bounds.delete(:y)})") {

              draw(svg, bounds, options.merge(@options))
            }
          else
            process(svg, options.merge(@options))
          end
        end
      end
      
      def draw(svg, bounds, options={})
        # Override this if visual component
      end

      def process(svg, options={})
        # Override this NOT a visual component
      end
      
      protected
        def relative(pct)
          @render_height * ( pct / 100.to_f )
        end
    end
  end
end