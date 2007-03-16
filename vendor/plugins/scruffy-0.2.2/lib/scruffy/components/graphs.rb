module Scruffy
  module Components
    
    # Component for displaying Graphs layers.
    #
    # Is passed all graph layers from the Graph object.
    #
    # (This may change as the capability for Graph filtering and such fills out.)
    class Graphs < Base
      STACKED_OPACITY = 0.85;
      
      def draw(svg, bounds, options={})
        # If Graph is limited to a category, reject layers outside of it's scope.
        applicable_layers = options[:layers].reject do |l| 
          if @options[:only]
            (l.options[:category].nil? && l.options[:categories].nil?) ||
            (!l.options[:category].nil? && l.options[:category] != @options[:only]) || 
            (!l.options[:categories].nil? && !l.options[:categories].include?(@options[:only]))
          else 
            false
          end
        end

        applicable_layers.each_with_index do |layer, idx|
          layer_options = {}
          layer_options[:index]       = idx
          layer_options[:min_value]   = options[:min_value]
          layer_options[:max_value]   = options[:max_value]
          layer_options[:complexity]  = options[:complexity]
          layer_options[:size]        = [bounds[:width], bounds[:height]]
          layer_options[:color]       = layer.preferred_color || layer.color || options[:theme].next_color
          layer_options[:opacity]     = opacity_for(idx)
          layer_options[:theme]       = options[:theme]

          svg.g(:id => "component_#{id}_graph_#{idx}", :class => 'graph_layer') {
            layer.render(svg, layer_options)
          }
        end # applicable_layers
      end # draw

      protected
        def opacity_for(idx)
          (idx == 0) ? 1.0 : (@options[:stacked_opacity] || STACKED_OPACITY)
        end

    end #class
  end
end