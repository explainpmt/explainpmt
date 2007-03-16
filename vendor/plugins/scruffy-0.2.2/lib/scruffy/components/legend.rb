module Scruffy::Components

  class Legend < Base
    def draw(svg, bounds, options={})
      legend_info = relevant_legend_info(options[:layers])
      active_width, points = layout(legend_info)

      offset = (bounds[:width] - active_width) / 2    # Nudge over a bit for true centering

      # Render Legend
      points.each_with_index do |point, idx|
        
        svg.rect( :x => offset + point, 
                  :y => relative(25), 
                  :width => relative(60), 
                  :height => relative(50),
                  :fill => legend_info[idx][:color])
                  
       svg.text(  legend_info[idx][:title], 
                  :x => offset + point + relative(100), 
                  :y => relative(80), 
                  'font-size' => relative(80), 
                  :fill => (options[:theme].marker || 'white'))
      end
    end   # draw
    
    protected
      # Collects Legend Info from the provided Layers.
      #
      # Automatically filters by legend's categories.
      def relevant_legend_info(layers, categories=(@options[:category] ? [@options[:category]] : @options[:categories]))
        legend_info = layers.inject([]) do |arr, layer|
          if categories.nil? ||
                (categories.include?(layer.options[:category]) ||
                (layer.options[:categories] && (categories & layer.options[:categories]).size > 0) )

            data = layer.legend_data
            arr << data if data.is_a?(Hash)
            arr = arr + data if data.is_a?(Array)
          end
          arr
        end
      end   # relevant_legend_info
      
      # Returns an array consisting of the total width needed by the legend information,
      # as well as an array of x-coords for each element.
      #
      # ie: [200, [0, 50, 100, 150]]
      def layout(legend_info_array)
        legend_info_array.inject([0, []]) do |enum, elem|
          enum[0] += (relative(50) * 2) if enum.first != 0      # Add spacer between elements
          enum[1] << enum.first                                 # Add location to points
          enum[0] += relative(50)                               # Add room for color box
          enum[0] += (relative(50) * elem[:title].length)       # Add room for text

          [enum.first, enum.last]
        end        
      end

  end   # class Legend
  
end   # Scruffy::Components