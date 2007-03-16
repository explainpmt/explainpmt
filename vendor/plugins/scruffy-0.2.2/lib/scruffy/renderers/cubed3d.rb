module Scruffy::Renderers
  # ===Scruffy::Renderers::Cubed3d
  #
  # Author:: Brasten Sager
  # Date:: August 17th, 2006
  #
  # A 3-dimensional cube effect.
  class Cubed3d < Empty
    VIEWPORT_SIZE = [25, 45]
    VIEWPORTS     = { :top_left => [10, 25],
                      :top_right => [55, 25],
                      :bottom_left => [10, 65],
                      :bottom_right => [55, 65] }
    
    # Returns a Cubed instance.
    def define_layout
      super do |components|
        components << Scruffy::Components::Title.new(:title, :position => [5, 2], :size => [90, 7])
                      
        components << Scruffy::Components::Viewport.new(:one, :position => [10, 50], 
                                                        :size => VIEWPORT_SIZE, :skewY => '-25', 
                                                        &graph_block(:one))
        components << Scruffy::Components::Viewport.new(:two, :position => [30, 50], 
                                                        :size => VIEWPORT_SIZE, :skewY => '-25', 
                                                        &graph_block(:two))
        components << Scruffy::Components::Viewport.new(:three, :position => [50, 50], 
                                                        :size => VIEWPORT_SIZE, :skewY => '-25', 
                                                        &graph_block(:three))
        components << Scruffy::Components::Viewport.new(:four, :position => [70, 50], 
                                                        :size => VIEWPORT_SIZE, :skewY => '-25', 
                                                        &graph_block(:four))


        components << Scruffy::Components::Legend.new(:legend, :position => [5, 13], :size => [90, 5])
      end
    end

    private
      # Returns a typical graph layout.
      #
      # These are squeezed into viewports.
      def graph_block(graph_filter)
        block = Proc.new { |components|
          components << Scruffy::Components::Grid.new(:grid, :position => [10, 0], :size => [90, 89])
          components << Scruffy::Components::ValueMarkers.new(:value_markers, :position => [0, 2], :size => [8, 89])
          components << Scruffy::Components::DataMarkers.new(:data_markers, :position => [10, 92], :size => [90, 8])
          components << Scruffy::Components::Graphs.new(:graphs, :position => [10, 0], :size => [90, 89], :only => graph_filter)
        }
        
        block
      end
  end
end