module Scruffy
  module Components
    class ValueMarkers < Base
      attr_accessor :markers
      
      def draw(svg, bounds, options={})
        markers = (options[:markers] || self.markers) || 5
        all_values = []

        (0...markers).each do |idx|
          marker = ((1 / (markers - 1).to_f) * idx) * bounds[:height]
          all_values << (options[:max_value] - options[:min_value]) * ((1 / (markers - 1).to_f) * idx) + options[:min_value]
        end
        
        (0...markers).each do |idx|
          marker = ((1 / (markers - 1).to_f) * idx) * bounds[:height]
          marker_value = (options[:max_value] - options[:min_value]) * ((1 / (markers - 1).to_f) * idx) + options[:min_value]
          marker_value = options[:value_formatter].route_format(marker_value, idx, options.merge({:all_values => all_values})) if options[:value_formatter]

          svg.text( marker_value.to_s, 
                    :x => bounds[:width], 
                    :y => (bounds[:height] - marker), 
                    'font-size' => relative(8),
                    :fill => ((options.delete(:marker_color_override) || options[:theme].marker) || 'white').to_s,
                    'text-anchor' => 'end')
        end
        
      end
    end
  end
end