module Scruffy
  module Components
    class Grid < Base
      attr_accessor :markers
      
      def draw(svg, bounds, options={})
        markers = (options[:markers] || self.markers) || 5
        
        (0...markers).each do |idx|
          marker = ((1 / (markers - 1).to_f) * idx) * bounds[:height]
          svg.line(:x1 => 0, :y1 => marker, :x2 => bounds[:width], :y2 => marker, :style => "stroke: #{options[:theme].marker.to_s}; stroke-width: 2;")
        end
      end
    end
  end
end