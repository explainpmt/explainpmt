# ==Scruffy::Layers
#
# Author:: Brasten Sager
# Date:: August 10th, 2006
#
# See documentation in Scruffy::Layers::Base
#
module Scruffy::Layers

  # Should be raised whenever a predictable error during rendering occurs,
  # particularly if you do not want to terminate the graph rendering process.
  class RenderError < StandardError; end
  
end

require 'scruffy/layers/base'
require 'scruffy/layers/area'
require 'scruffy/layers/all_smiles'
require 'scruffy/layers/bar'
require 'scruffy/layers/line'
require 'scruffy/layers/average'
require 'scruffy/layers/stacked'
