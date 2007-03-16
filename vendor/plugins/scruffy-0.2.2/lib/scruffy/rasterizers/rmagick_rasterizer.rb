module Scruffy::Rasterizers

  # == RMagickRasterizer
  #
  # Author:: Brasten Sager
  # Date:: August 14th, 2006
  #
  # The RMagickRasterizer converts SVG graphs to images using ImageMagick.
  class RMagickRasterizer
    def rasterize(svg, options={})
      
      # I know this seems weird, I'm open to suggestions.
      # I didn't want RMagick required unless absolutely necessary.
      require 'RMagick'

      image = Magick::Image::from_blob(svg)[0]

      # Removed for now
      # image.resize!(options[:size][0], options[:size][1], Magick::BoxFilter, 1.25) if options[:actual_size]

      if options[:to]
        image.write(options[:to]) { self.format = options[:as] }
      end

      image.to_blob { self.format = options[:as] }
    end
  end
end