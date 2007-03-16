module Scruffy::Helpers
  # ==Scruffy::Helpers::Canvas
  #
  # Author:: Brasten Sager
  # Date:: August 16th, 2006
  #
  # Provides common methods for canvas objects.  Primarily used for providing spacial-type calculations
  # where necessary.
  module Canvas
    attr_accessor :components
    
    def reset_settings!
      self.options = {}
    end
    
    def component(id, components=self.components)
      components.find { |elem| elem.id == id }
    end
    
    def remove(id, components=self.components)
      components.delete(component(id))
    end
    
    protected
      # Converts percentage values into actual pixe values based on the known render size.
      #
      # Returns a hash consisting of :x, :y, :width, and :height elements.
      def bounds_for(canvas_size, position, size)
        return nil if (position.nil? || size.nil?)
        bounds = {}
        bounds[:x] = canvas_size.first * (position.first / 100.to_f)
        bounds[:y] = canvas_size.last  * (position.last  / 100.to_f)
        bounds[:width] = canvas_size.first * (size.first / 100.to_f)
        bounds[:height] = canvas_size.last * (size.last  / 100.to_f)
        bounds
      end
  end # canvas
  
end # scruffy::helpers