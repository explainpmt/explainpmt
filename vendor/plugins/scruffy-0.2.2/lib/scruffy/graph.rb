module Scruffy
  
  # ==Scruffy Graphs
  #
  # Author:: Brasten Sager
  # Date:: August 5th, 2006
  #
  #
  # ====Graphs vs. Layers (Graph Types)
  #
  # Scruffy::Graph is the primary class you will use to generate your graphs.  A Graph does not
  # define a graph type nor does it directly hold any data.  Instead, a Graph object can be thought
  # of as a canvas on which other graphs are draw.  (The actual graphs themselves are subclasses of Scruffy::Layers::Base)
  # Despite the technical distinction, we will refer to Scruffy::Graph objects as 'graphs' and Scruffy::Layers as
  # 'layers' or 'graph types.'
  #
  #
  # ==== Creating a Graph
  #
  # You can begin building a graph by instantiating a Graph object and optionally passing a hash
  # of properties.
  #
  #   graph = Scruffy::Graph.new
  #
  #   OR
  #
  #   graph = Scruffy::Graph.new(:title => "Monthly Profits", :theme => Scruffy::Themes::RubyBlog.new)
  #
  # Once you have a Graph object, you can set any Graph-level properties (title, theme, etc), or begin adding
  # graph layers.  You can add a graph layer to a graph by using the Graph#add or Graph#<< methods.  The two
  # methods are identical and used to accommodate syntax preferences.
  #
  #   graph.add(:line, 'John', [100, -20, 30, 60])
  #   graph.add(:line, 'Sara', [120, 50, -80, 20])
  #
  #   OR
  #
  #   graph << Scruffy::Layers::Line.new(:title => 'John', :points => [100, -20, 30, 60])
  #   graph << Scruffy::Layers::Line.new(:title => 'Sara', :points => [120, 50, -80, 20])  
  #
  # Now that we've created our graph and added a layer to it, we're ready to render!  You can render the graph
  # directly to SVG or any other image format (supported by RMagick) with the Graph#render method:
  #
  #   graph.render    # Renders a 600x400 SVG graph
  #
  #   OR
  #
  #   graph.render(:width => 1200)
  #
  #   # For image formats other than SVG:
  #   graph.render(:width => 1200, :as => 'PNG')
  #
  #   # To render directly to a file:
  #   graph.render(:width => 5000, :to => '<filename>')
  #
  #   graph.render(:width => 700, :as => 'PNG', :to => '<filename>')
  #
  # And that's your basic Scruffy graph!  Please check the documentation for the various methods and
  # classes you'll be using, as there are a bunch of options not demonstrated here.
  #
  # A couple final things worth noting:
  # * You can call Graph#render as often as you wish with different rendering options.  In
  #   fact, you can modify the graph any way you wish between renders.
  #
  #
  # * There are no restrictions to the combination of graph layers you can add.  It is perfectly
  #   valid to do something like:
  #     graph.add(:line, [100, 200, 300])
  #     graph.add(:bar, [200, 150, 150])
  #
  #   Of course, while you may be able to combine some things such as pie charts and line graphs, that
  #   doesn't necessarily mean they will make any logical sense together.  We leave those decisions up to you. :)
  class Graph
    include Scruffy::Helpers::LayerContainer
    
    attr_accessor :title
    attr_accessor :theme
    attr_accessor :default_type
    attr_accessor :point_markers
    attr_accessor :value_formatter
    attr_accessor :rasterizer
    
    attr_reader :renderer     # Writer defined below
    
    # Returns a new Graph.  You can optionally pass in a default graph type and an options hash.
    #
    #   Graph.new           # New graph
    #   Graph.new(:line)    # New graph with default graph type of Line
    #   Graph.new({...})    # New graph with options.
    #
    # Options:
    #
    # title::  Graph's title
    # theme::  A theme object to use when rendering graph
    # layers::  An array of Layers for this graph to use
    # default_type::  A symbol indicating the default type of Layer for this graph
    # value_formatter::   Sets a formatter used to modify marker values prior to rendering
    # point_markers::  Sets the x-axis marker values
    # rasterizer::  Sets the rasterizer to use when rendering to an image format.  Defaults to RMagick.
    def initialize(*args)
      self.default_type   = args.shift if args.first.is_a?(Symbol)
      options             = args.shift.dup if args.first.is_a?(Hash)
      raise ArgumentError, "The arguments provided are not supported." if args.size > 0

      options ||= {}
      self.theme = Scruffy::Themes::Keynote.new
      self.renderer = Scruffy::Renderers::Standard.new
      self.rasterizer = Scruffy::Rasterizers::RMagickRasterizer.new
      self.value_formatter = Scruffy::Formatters::Number.new

      %w(title theme layers default_type value_formatter point_markers rasterizer).each do |arg|
        self.send("#{arg}=".to_sym, options.delete(arg.to_sym)) unless options[arg.to_sym].nil?
      end
      
      raise ArgumentError, "Some options provided are not supported: #{options.keys.join(' ')}." if options.size > 0
    end
    
    # Renders the graph in it's current state to an SVG object.
    #
    # Options:
    # size:: An array indicating the size you wish to render the graph.  ( [x, y] )
    # width:: The width of the rendered graph.  A height is calculated at 3/4th of the width.
    # theme:: Theme used to render graph for this render only.
    # min_value:: Overrides the calculated minimum value used for the graph.
    # max_value:: Overrides the calculated maximum value used for the graph.
    #
    # For other image formats:
    # as:: File format to render to ('PNG', 'JPG', etc)
    # to:: Name of file to save graph to, if desired.  If not provided, image is returned as blob/string.
    def render(options = {})
      options[:theme]               ||= theme
      options[:value_formatter]     ||= value_formatter
      options[:point_markers]       ||= point_markers
      options[:size]                ||= (options[:width] ? [options[:width], (options.delete(:width) * 0.6).to_i] : [600, 360])
      options[:title]               ||= title
      options[:layers]              ||= layers
      options[:min_value]           ||= bottom_value(:padded)
      options[:max_value]           ||= top_value
      options[:graph]               ||= self
      

      # Removed for now.
      # Added for making smaller fonts more legible, but may not be needed after all.
      #
      # if options[:as] && (options[:size][0] <= 300 || options[:size][1] <= 200)
      #   options[:actual_size] = options[:size]
      #   options[:size] = [800, (800.to_f * (options[:actual_size][1].to_f / options[:actual_size][0].to_f))]
      # end
      
      svg = ( options[:renderer].nil? ? self.renderer.render( options ) : options[:renderer].render( options ) )
      
      # SVG to file.
      if options[:to] && options[:as].nil?
        File.open(options[:to], 'w') { |file|
          file.write(svg)
        }
      end
      
      options[:as] ? rasterizer.rasterize(svg, options) : svg
    end
    
    def renderer=(val)
      raise ArgumentError, "Renderer must include a #render(options) method." unless (val.respond_to?(:render) && val.method(:render).arity.abs > 0)
      
      @renderer = val
    end
    
    alias :layout :renderer
    
    def component(id)
      renderer.component(id)
    end
    
    def remove(id)
      renderer.remove(id)
    end
  end
end