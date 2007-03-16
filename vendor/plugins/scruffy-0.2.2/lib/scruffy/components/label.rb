module Scruffy
  module Components
    class Label < Base
      def draw(svg, bounds, options={})
        svg.text(@options[:text], :class => 'text', :x => (bounds[:width] / 2), :y => bounds[:height], 
                'font-size' => relative(100), :fill => options[:theme].marker, :stroke => 'none', 'stroke-width' => '0',
                'text-anchor' => (@options[:text_anchor] || 'middle'))
      end
    end
  end
end