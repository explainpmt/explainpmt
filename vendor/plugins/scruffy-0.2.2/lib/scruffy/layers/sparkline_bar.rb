module Scruffy
  module Layers
    # Experimental, do not use.
    class SparklineBar < Base
    
      def draw(svg, coords, options = {})
        zero_point = @height / 2.0

        coords.each do |coord|
          x, y, bar_height = (coord.first-(@bar_width * 0.5)), coord.last, (height - coord.last)

          bar_color = (y > zero_point) ? 'black' : 'red'
          bar_height = (bar_height - zero_point)
          
          #y = (bar_height < 0) ? 

          # svg.rect( :x => x, :y => zero_point, :width => @bar_width, :height => , 
          #           :fill => bar_color, :stroke => 'none', 'style' => "opacity: #{opacity}" )
        end
      end

      protected
        def generate_coordinates(options = {})
          @bar_width = (width / points.size) * 0.9
          options[:point_distance] = (width - (width / points.size)) / (points.size - 1).to_f

          coords = (0...points.size).map do |idx| 
            x_coord = (options[:point_distance] * idx) + (width / points.size * 0.5)

            relative_percent = ((points[idx] == min_value) ? 0 : ((points[idx] - min_value) / (max_value - min_value).to_f))
            y_coord = (height - (height * relative_percent))
            [x_coord, y_coord]
          end
          coords
        end
    end
  end
end