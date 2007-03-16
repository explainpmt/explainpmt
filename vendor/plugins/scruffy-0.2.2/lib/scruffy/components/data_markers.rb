module Scruffy
  module Components

    class DataMarkers < Base

      def draw(svg, bounds, options={})
        unless options[:point_markers].nil?
          point_distance = bounds[:width] / (options[:point_markers].size - 1).to_f
    
          (0...options[:point_markers].size).map do |idx| 
            x_coord = point_distance * idx
            svg.text(options[:point_markers][idx], :x => x_coord, :y => bounds[:height], 
                     'font-size' => relative(90), 
                     :fill => (options[:theme].marker || 'white').to_s, 
                     'text-anchor' => 'middle') unless options[:point_markers][idx].nil?
          end
        end
      end   # draw
      
    end   # class

  end
end