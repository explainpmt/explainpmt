module Scruffy
  module Renderers
    # Experimental, do not use.
    class Sparkline < Base
      def define_layout
        self.components << Scruffy::Components::Graphs.new(:sparkline, :position => [0, 0], :size => [100, 100])                  
      end
    end
  end
end