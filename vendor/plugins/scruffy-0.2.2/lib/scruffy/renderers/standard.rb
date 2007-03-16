module Scruffy::Renderers
  class Standard < Empty
    
    def define_layout
      super do |components|
        components << Scruffy::Components::Title.new(:title, :position => [5, 2], :size => [90, 7])
        components << Scruffy::Components::Viewport.new(:view, :position => [2, 26], :size => [89, 66]) do |graph|
          graph << Scruffy::Components::ValueMarkers.new(:values, :position => [0, 2], :size => [18, 89])
          graph << Scruffy::Components::Grid.new(:grid, :position => [20, 0], :size => [80, 89])
          graph << Scruffy::Components::DataMarkers.new(:labels, :position => [20, 92], :size => [80, 8])
          graph << Scruffy::Components::Graphs.new(:graphs, :position => [20, 0], :size => [80, 89])
        end
        components << Scruffy::Components::Legend.new(:legend, :position => [5, 13], :size => [90, 6])
      end
    end
    
    protected
      def hide_values
        super
        component(:view).position[0] = -10
        component(:view).size[0] = 100
      end
    
      def labels
        [component(:view).component(:labels)]
      end
    
      def values
        [component(:view).component(:values)]
      end
      
      def grids
        [component(:view).component(:grid)]
      end
  end
end