module Scruffy::Renderers
  # ===Scruffy::Renderers::Cubed
  #
  # Author:: Brasten Sager
  # Date:: August 14th, 2006
  #
  # Graph layout consisting of four separate graphs arranged in a 2x2 grid.
  class Cubed < Empty
    VIEWPORT_SIZE = [35, 30]
    VIEWPORTS     = { :top_left => [10, 25],
                      :top_right => [55, 25],
                      :bottom_left => [10, 65],
                      :bottom_right => [55, 65] }
    
    # Returns a Cubed instance.
    def define_layout
      super do |components|
        components << Scruffy::Components::Title.new(:title, :position => [5, 2], :size => [90, 7])
                      
        VIEWPORTS.each_pair do |category, position|
          components << Scruffy::Components::Viewport.new(category, :position => position, 
                                                          :size => VIEWPORT_SIZE, &graph_block(category))
        end

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