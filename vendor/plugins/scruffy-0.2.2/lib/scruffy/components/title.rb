module Scruffy
  module Components
    class Title < Base
      def draw(svg, bounds, options={})
        svg.text(options[:title], :class => 'title', :x => (bounds[:width] / 2), :y => bounds[:height], 
                'font-size' => relative(100), :fill => options[:theme].marker, :stroke => 'none', 'stroke-width' => '0',
                'text-anchor' => (@options[:text_anchor] || 'middle'))
      end
    end
  end
end