# ===Scruffy Renderers
#
# Author:: Brasten Sager
# Date:: August 14th, 2006
#
# Renderers piece the entire graph together from a collection
# of components.  Creating new renderers allows you to create
# entirely new layouts for your graphs.
#
# Scruffy::Renderers::Base contains the basic functionality needed
# by a layout.  The easiest way to create a new layout is by subclassing
# Base.
module Scruffy::Renderers; end

require 'scruffy/renderers/base'
require 'scruffy/renderers/empty'
require 'scruffy/renderers/standard'
require 'scruffy/renderers/reversed'
require 'scruffy/renderers/cubed'
require 'scruffy/renderers/split'
require 'scruffy/renderers/cubed3d'