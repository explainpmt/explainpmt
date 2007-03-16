module Scruffy::Layers
  # ==Scruffy::Layers::Stacked
  #
  # Author:: Brasten Sager
  # Date:: August 12th, 2006
  #
  # Provides a generic way for stacking graphs.  This may or may not
  # do what you'd expect under every situation, but it at least kills
  # a couple birds with one stone (stacked bar graphs and stacked area
  # graphs work fine).
  class Stacked < Base
    include Scruffy::Helpers::LayerContainer
    
    # Returns new Stacked graph.
    #
    # You can provide a block for easily adding layers during (just after) initialization.
    # Example:
    #   Stacked.new do |stacked|
    #     stacked << Scruffy::Layers::Line.new( ... )
    #     stacked.add(:bar, 'My Bar', [...])
    #   end
    #
    # The initialize method passes itself to the block, and since stacked is a LayerContainer,
    # layers can be added just as if they were being added to Graph.
    def initialize(options={}, &block)
      super(options)

      block.call(self)    # Allow for population of data with a block during initialization.
    end
    
    # Overrides Base#render to fiddle with layers' points to achieve a stacked effect.
    def render(svg, options = {})
      current_points = points.dup
      
      layers.each do |layer|
        real_points = layer.points
        layer.points = current_points
        layer_options = options.dup
        layer_options[:color] = layer.preferred_color || layer.color || options[:theme].next_color          
        layer.render(svg, layer_options)
        options.merge(layer_options)
        layer.points = real_points
        
        layer.points.each_with_index { |val, idx| current_points[idx] -= val }
      end
    end

    # A stacked graph has many data sets.  Return legend information for all of them.
    def legend_data
      if relevant_data?
        retval = []
        layers.each do |layer|
          retval << layer.legend_data
        end
        retval
      else
        nil
      end
    end

    # The highest data point on this layer, or nil if relevant_data == false
    def top_value
      @relevant_data ? points.sort.last : nil
    end
  
    def points
      longest_arr = layers.inject(nil) do |longest, layer|
        longest = layer.points if (longest.nil? || longest.size < layer.points.size)
      end
      
      summed_points = (0...longest_arr.size).map do |idx|
        layers.inject(nil) do |sum, layer|
          if sum.nil? && !layer.points[idx].nil?
            sum = layer.points[idx]
          elsif !layer.points[idx].nil?
            sum += layer.points[idx]
          end
          
          sum
        end
      end

      summed_points
    end

    def points=(val)
      throw ArgumentsError, "Stacked layers cannot accept points, only other layers."
    end
  end
end