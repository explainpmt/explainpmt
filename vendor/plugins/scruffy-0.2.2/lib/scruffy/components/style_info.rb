module Scruffy
  module Components
    # Component used for adding CSS styling to SVG graphs.
    #
    # In hindsight, ImageMagick and Mozilla SVG's handling of CSS styling is
    # extremely inconsistant, so use this at your own risk.
    class StyleInfo < Base
      def initialize(*args)
        super
        
        @visible = false
      end
      def process(svg, options={})
        svg.defs {
          svg.style(:type => "text/css") {
            svg.cdata!("\n#{options[:selector]} {\n    #{options[:style]}\n}\n")
          }
        }
      end
    end
  end
end