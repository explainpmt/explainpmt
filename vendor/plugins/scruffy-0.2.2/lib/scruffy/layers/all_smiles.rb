module Scruffy::Layers
  # ==Scruffy::Layers::AllSmiles
  #
  # Author:: Brasten Sager
  # Date:: August 8th, 2006
  #
  # The AllSmiles graph consists of smiley faces for data points, with smiles or frowns depending upon
  # their relative location on the graph.  The highest point is crowned with a wizard hat.  The Wizard
  # Smiley eventually become 'Scruffy', our mascot.
  #
  # I don't know why.
  #
  # This graph only looks decent in SVG mode.  If you're rasterizing the graph with ImageMagick, you
  # must use the :complexity => :minimal option on Graph#render.  This will make the graph look really
  # nasty, but still better than if you try to rasterize with all the gradients in place.
  class AllSmiles < Base
    attr_accessor :standalone

    # Returns a new AllSmiles graph.
    #
    # Options:
    # standalone:: If set to true, dashed lines under smilies run vertically, like bar graphs.
    #              If false (default), dashed lines run from smiley to smiley, like a line-graph.
    def initialize(options = {})
      super
      @standalone = options[:standalone] || false
    end
  
    # Renders graph.
    def draw(svg, coords, options={})
    
      hero_smiley = nil
      coords.each { |c| hero_smiley = c.last if (hero_smiley.nil? || c.last < hero_smiley) }
    
      svg.defs {
        svg.radialGradient(:id => 'SmileyGradient', :cx => '50%', 
                           :cy => '50%', :r => '50%', :fx => '30%', :fy => '30%') {
                           
            svg.stop(:offset => '0%', 'stop-color' => '#FFF')
            svg.stop(:offset => '20%', 'stop-color' => '#FFC')
            svg.stop(:offset => '45%', 'stop-color' => '#FF3')
            svg.stop(:offset => '60%', 'stop-color' => '#FF0')
            svg.stop(:offset => '90%', 'stop-color' => '#990')
            svg.stop(:offset => '100%', 'stop-color' => '#220')
        }
        svg.radialGradient(:id => 'HeroGradient', :cx => '50%', 
                           :cy => '50%', :r => '50%', :fx => '30%', :fy => '30%') {
                           
            svg.stop(:offset => '0%', 'stop-color' => '#FEE')
            svg.stop(:offset => '20%', 'stop-color' => '#F0E0C0')
            svg.stop(:offset => '45%', 'stop-color' => '#8A2A1A')
            svg.stop(:offset => '60%', 'stop-color' => '#821')
            svg.stop(:offset => '90%', 'stop-color' => '#210')
        }
        svg.radialGradient(:id => 'StarGradient', :cx => '50%', 
                           :cy => '50%', :r => '50%', :fx => '30%', :fy => '30%') {
                           
            svg.stop(:offset => '0%', 'stop-color' => '#FFF')
            svg.stop(:offset => '20%', 'stop-color' => '#EFEFEF')
            svg.stop(:offset => '45%', 'stop-color' => '#DDD')
            svg.stop(:offset => '60%', 'stop-color' => '#BBB')
            svg.stop(:offset => '90%', 'stop-color' => '#888')
        }
      }
          
      unless standalone
        svg.polyline( :points => stringify_coords(coords).join(' '), :fill => 'none', 
                      :stroke => '#660', 'stroke-width' => scaled(10), 'stroke-dasharray' => "#{scaled(10)}, #{scaled(10)}" )
      end
    
      # Draw smilies.
      coords.each do |coord|
        if standalone
          svg.line( :x1 => coord.first, :y1 => coord.last, :x2 => coord.first, :y2 => height, :fill => 'none', 
                        :stroke => '#660', 'stroke-width' => scaled(10), 'stroke-dasharray' => "#{scaled(10)}, #{scaled(10)}" )
        end
        svg.circle( :cx => coord.first + scaled(2), :cy => coord.last + scaled(2), :r => scaled(15), 
                    :fill => 'black', :stroke => 'none', :opacity => 0.4)
        svg.circle( :cx => coord.first, :cy => coord.last, :r => scaled(15), 
                    :fill => (complexity == :minimal ? 'yellow' : 'url(#SmileyGradient)'), :stroke => 'black', 'stroke-width' => scaled(1) )
        svg.line( :x1 => (coord.first - scaled(3)), 
                  :x2 => (coord.first - scaled(3)),
                  :y1 => (coord.last),
                  :y2 => (coord.last  - scaled(7)), :stroke => 'black', 'stroke-width' => scaled(1.4) )
        svg.line( :x1 => (coord.first + scaled(3)), 
                  :x2 => (coord.first + scaled(3)),
                  :y1 => (coord.last),
                  :y2 => (coord.last  - scaled(7)), :stroke => 'black', 'stroke-width' => scaled(1.4) )
                
      
        # Some minor mathematics for the smile/frown
        percent = 1.0 - (coord.last.to_f / height.to_f)
        corners = scaled(8 - (5 * percent))
        anchor  = scaled((20 * percent) - 5)
        
        # Draw the mouth
        svg.path( :d => "M#{coord.first - scaled(9)} #{coord.last + corners} Q#{coord.first} #{coord.last + anchor} #{coord.first + scaled(9)} #{coord.last + corners}",
                  :stroke => 'black', 'stroke-width' => scaled(1.4), :fill => 'none' )
                
                
        # Wizard hat for hero smiley.
        if coord.last == hero_smiley
          svg.ellipse(:cx => coord.first, :cy => (coord.last - scaled(13)), 
                      :rx => scaled(17), :ry => scaled(6.5), :fill => (complexity == :minimal ? 'purple' : 'url(#HeroGradient)'), :stroke => 'black', 'stroke-width' => scaled(1.4) )
        
          svg.path(:d => "M#{coord.first} #{coord.last - scaled(60)} " +
                         "L#{coord.first + scaled(10)} #{coord.last - scaled(14)} " +
                         "C#{coord.first + scaled(10)},#{coord.last - scaled(9)} #{coord.first - scaled(10)},#{coord.last - scaled(9)} #{coord.first - scaled(10)},#{coord.last - scaled(14)}" +
                         "L#{coord.first} #{coord.last - scaled(60)}",
                    :stroke => 'black', 'stroke-width' => scaled(1.4), :fill => (complexity == :minimal ? 'purple' : 'url(#HeroGradient)'))

          svg.path(:d =>  "M#{coord.first - scaled(4)} #{coord.last - scaled(23)}" +
                          "l-#{scaled(2.5)} #{scaled(10)} l#{scaled(7.5)} -#{scaled(5)} l-#{scaled(10)} 0 l#{scaled(7.5)} #{scaled(5)} l-#{scaled(2.5)} -#{scaled(10)}", :stroke => 'none', :fill => (complexity == :minimal ? 'white': 'url(#StarGradient)') )
          svg.path(:d =>  "M#{coord.first + scaled(2)} #{coord.last - scaled(30)}" +
                          "l-#{scaled(2.5)} #{scaled(10)} l#{scaled(7.5)} -#{scaled(5)} l-#{scaled(10)} 0 l#{scaled(7.5)} #{scaled(5)} l-#{scaled(2.5)} -#{scaled(10)}", :stroke => 'none', :fill => (complexity == :minimal ? 'white': 'url(#StarGradient)') )
          svg.path(:d =>  "M#{coord.first - scaled(2)} #{coord.last - scaled(33)}" +
                          "l-#{scaled(1.25)} #{scaled(5)} l#{scaled(3.75)} -#{scaled(2.5)} l-#{scaled(5)} 0 l#{scaled(3.75)} #{scaled(2.5)} l-#{scaled(1.25)} -#{scaled(5)}", :stroke => 'none', :fill => 'white' )
          svg.path(:d =>  "M#{coord.first - scaled(2.2)} #{coord.last - scaled(32.7)}" +
                          "l-#{scaled(1.25)} #{scaled(5)} l#{scaled(3.75)} -#{scaled(2.5)} l-#{scaled(5)} 0 l#{scaled(3.75)} #{scaled(2.5)} l-#{scaled(1.25)} -#{scaled(5)}", :stroke => 'none', :fill => (complexity == :minimal ? 'white': 'url(#StarGradient)') )
          svg.path(:d =>  "M#{coord.first + scaled(4.5)} #{coord.last - scaled(20)}" +
                          "l-#{scaled(1.25)} #{scaled(5)} l#{scaled(3.75)} -#{scaled(2.5)} l-#{scaled(5)} 0 l#{scaled(3.75)} #{scaled(2.5)} l-#{scaled(1.25)} -#{scaled(5)}", :stroke => 'none', :fill => (complexity == :minimal ? 'white': 'url(#StarGradient)') )
          svg.path(:d =>  "M#{coord.first} #{coord.last - scaled(40)}" +
                          "l-#{scaled(1.25)} #{scaled(5)} l#{scaled(3.75)} -#{scaled(2.5)} l-#{scaled(5)} 0 l#{scaled(3.75)} #{scaled(2.5)} l-#{scaled(1.25)} -#{scaled(5)}", :stroke => 'none', :fill => (complexity == :minimal ? 'white': 'url(#StarGradient)') )

        end

      end
    end

    # Legacy (4 days old).  Removed scaled from layout engine, 
    # changed to #relative, with different math involved.
    # Translate here so I don't have to entirely redo this graph.
    def scaled(pt)
      relative(pt) / 2
    end
  end
end