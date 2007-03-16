module Scruffy::Layers
  # ==Scruffy::Layers::Area
  #
  # Author:: Brasten Sager
  # Date:: August 6th, 2006
  #
  # Standard area graph.
  class Area < Base
    
    # Render area graph.
    def draw(svg, coords, options={})
      # svg.polygon wants a long string of coords. 
      points_value = "0,#{height} #{stringify_coords(coords).join(' ')} #{width},#{height}"

      # Experimental, for later user.
      # This was supposed to add some fun filters, 3d effects and whatnot.
      # Neither ImageMagick nor Mozilla SVG render this well (at all).  Maybe a future thing.
      #
      # svg.defs {
      #   svg.filter(:id => 'MyFilter', :filterUnits => 'userSpaceOnUse', :x => 0, :y => 0, :width => 200, :height => '120') {
      #     svg.feGaussianBlur(:in => 'SourceAlpha', :stdDeviation => 4, :result => 'blur')
      #     svg.feOffset(:in => 'blur', :dx => 4, :dy => 4, :result => 'offsetBlur')
      #     svg.feSpecularLighting( :in => 'blur', :surfaceScale => 5, :specularConstant => '.75',
      #                             :specularExponent => 20, 'lighting-color' => '#bbbbbb',
      #                             :result => 'specOut') {
      #       svg.fePointLight(:x => '-5000', :y => '-10000', :z => '20000')
      #     }
      #     
      #     svg.feComposite(:in => 'specOut', :in2 => 'SourceAlpha', :operator => 'in', :result => 'specOut')
      #     svg.feComposite(:in => 'sourceGraphic', :in2 => 'specOut', :operator => 'arithmetic',
      #                     :k1 => 0, :k2 => 1, :k3 => 1, :k4 => 0, :result => 'litPaint')
      #                     
      #     svg.feMerge {
      #       svg.feMergeNode(:in => 'offsetBlur')
      #       svg.feMergeNode(:in => 'litPaint')
      #     }
      #   }
      # }
      svg.g(:transform => "translate(0, -#{relative(2)})") {
        svg.polygon(:points => points_value, :style => "fill: black; stroke: black; fill-opacity: 0.06; stroke-opacity: 0.06;")
      }

      svg.polygon(:points => points_value, :fill => color.to_s, :stroke => color.to_s, 'style' => "opacity: #{opacity}")
    end
  end
end