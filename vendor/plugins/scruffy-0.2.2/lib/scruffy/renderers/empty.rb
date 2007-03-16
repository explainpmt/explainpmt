module Scruffy::Renderers
  # ===Scruffy::Renderers::Empty
  #
  # Author:: Brasten Sager
  # Date:: August 17th, 2006
  #
  # An Empty graph isn't completely empty, it adds a background componenet
  # to itself before handing other all other layout responsibilities to it's
  # subclasses or caller.
  class Empty < Base

    # Returns a renderer with just a background.
    #
    # If a block is provided, the components array is passed to
    # the block, allowing callers to add components during initialize.
    def define_layout
      self.components << Scruffy::Components::Background.new(:background, :position => [0,0], :size =>[100, 100])      

      yield(self.components) if block_given?
    end
  end
end