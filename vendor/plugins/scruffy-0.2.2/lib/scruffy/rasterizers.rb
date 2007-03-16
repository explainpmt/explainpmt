# ===Scruffy Rasterizers
#
# Author:: Brasten Sager
# Date:: August 10th, 2006
#
# These handle the job of rasterizing SVG images to other image formats.
# At the moment, only RMagickRasterizer exists, but others may soon follow.
#
# I'm somewhat interesting in finding a way to integrate Apache Batik, as it's
# SVG rendering seems to be superior to ImageMagick's.
module Scruffy::Rasterizers; end

require 'scruffy/rasterizers/rmagick_rasterizer.rb'
require 'scruffy/rasterizers/batik_rasterizer.rb'
