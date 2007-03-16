# ===Scruffy Graphing Library for Ruby
#
# Author:: Brasten Sager
# Date:: August 5th, 2006
#
# For information on generating graphs using Scruffy, see the
# documentation in Scruffy::Graph.
#
# For information on creating your own graph types, see the
# documentation in Scruffy::Layers::Base.
module Scruffy; end


$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'rubygems'
require 'builder'

require 'scruffy/helpers'
require 'scruffy/graph'
require 'scruffy/themes'
require 'scruffy/version'
require 'scruffy/formatters'
require 'scruffy/rasterizers'
require 'scruffy/layers'
require 'scruffy/components'
require 'scruffy/renderers'