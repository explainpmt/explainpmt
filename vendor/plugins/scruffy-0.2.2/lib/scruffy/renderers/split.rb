module Scruffy
  module Renderers
    # Renderer that splits the graphs up into four other little graphs.
    class Split < Empty
      def define_layout
        super do |components|
          components << Scruffy::Components::Title.new(:title, :position => [5, 2], :size => [90, 7])
          components << Scruffy::Components::Label.new(:label_one, :text => self.options[:split_label] || '', 
                                                      :position => [30, 54.5], :size => [40, 3])

          # Viewports
          components << Scruffy::Components::Viewport.new(:top, :position => [3, 20], 
                                                         :size => [90, 30], &graph_block(:top))
          components << Scruffy::Components::Viewport.new(:bottom, :position => [3, 65], 
                                                         :size => [90, 30], &graph_block(:bottom))
        
          components << Scruffy::Components::Legend.new(:legend, :position => [5, 11], :size => [90, 4])
        end
      end

      protected
        def labels
          [component(:top).component(:labels), component(:bottom).component(:labels)]
        end
    
        def values
          [component(:top).component(:values), component(:bottom).component(:values)]
        end
      
        def grids
          [component(:top).component(:grid), component(:bottom).component(:grid)]
        end
      

      private
        def graph_block(graph_filter)
          block = Proc.new { |components|
            components << Scruffy::Components::Grid.new(:grid, :position => [10, 0], :size => [90, 89])
            components << Scruffy::Components::ValueMarkers.new(:values, :position => [0, 2], :size => [8, 89])
            components << Scruffy::Components::DataMarkers.new(:labels, :position => [10, 92], :size => [90, 8])
            components << Scruffy::Components::Graphs.new(:graphs, :position => [10, 0], :size => [90, 89], :only => graph_filter)
          }
          
          block
        end
    end
  end
end