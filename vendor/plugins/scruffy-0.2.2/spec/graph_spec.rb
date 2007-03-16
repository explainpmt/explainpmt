require 'lib/scruffy'
require 'fileutils'

module CustomRenderers
  def blank_renderer
    object = Object.new
    object.instance_eval { class << self;self;end }.instance_eval { define_method :render do |options|
        puts "Rendering"
      end
    }
    object
  end
end

context "A new Scruffy::Graph" do
  include CustomRenderers
  
  setup do
    @graph = Scruffy::Graph.new
  end
  
  specify "should have a blank title" do
    @graph.title.should_be.nil
  end
  
  specify "should be set to the keynote theme" do
    @graph.theme.should_equal Scruffy::Themes::KEYNOTE
  end
  
  specify "should have zero layers" do
    @graph.should_have(0).layers
  end
  
  specify "should not have a default layer type" do
    @graph.default_type.should_be.nil
  end
  
  specify "should not have any point markers (x-axis values)" do
    @graph.point_markers.should_be.nil
  end
  
  specify "should not have a marker transformer" do
    @graph.marker_transformer.should_be.nil
  end
  
  specify "should use a StandardRenderer" do
    @graph.renderer.should_be_instance_of Scruffy::StandardRenderer
  end
  
  specify "should accept a new title" do
    @graph.title = "New Title"
    @graph.title.should_equal "New Title"
  end
  
  specify "should accept a new theme" do
    @graph.theme = Scruffy::Themes::MEPHISTO
    @graph.theme.should_equal Scruffy::Themes::MEPHISTO
  end
  
  specify "should accept a new default type" do
    @graph.default_type = :line
    @graph.default_type.should_equal :line
  end
  
  specify "should accept new point markers" do
    markers = ['Jan', 'Feb', 'Mar']
    @graph.point_markers = markers
    @graph.point_markers.should_equal markers
  end
  
  specify "should accept a new renderer" do
    renderer = blank_renderer
    @graph.renderer = renderer
    @graph.renderer.should_equal renderer
  end
  
  specify "should not accept renderers with missing #render methods" do
      lambda { @graph.renderer = 1 }.should_raise ArgumentError
  end
end

context "A Scruffy::Graph's initialization block" do
  include CustomRenderers
  
  specify "should accept just a default_type Symbol" do
    lambda { Scruffy::Graph.new(:line) }.should_not_raise
  end
  
  specify "should accept just an options hash" do
    lambda { Scruffy::Graph.new({:title => "My Title"}) }.should_not_raise
    lambda { Scruffy::Graph.new(:title => "My Title", :theme => Scruffy::Themes::KEYNOTE) }.should_not_raise
  end
  
  specify "should accept both a default_type and options hash" do
    lambda {
      Scruffy::Graph.new(:line, {:title => "My Title"})
      Scruffy::Graph.new(:line, :title => "My Title")
    }.should_not_raise
  end
  
  specify "should reject any invalid argument combination" do
    lambda { Scruffy::Graph.new({:title => "My Title"}, :line) }.should_raise ArgumentError
    lambda { Scruffy::Graph.new(:line, {:title => "My Title"}, "Any additional arguments.") }.should_raise ArgumentError
    lambda { Scruffy::Graph.new(:line, "Any additional arguments.") }.should_raise ArgumentError    
  end
  
  specify "should reject any options that are not supported" do
    lambda { Scruffy::Graph.new(:title => "My Title", :some_key => "Some Value") }.should_raise ArgumentError
  end
  
  specify "should successfully save all valid options" do
      options = {:title => "My Title",
                 :theme => {:background => [:black], 
                            :colors => [:red => 'red', :yellow => 'yellow']},
                 :layers => [ Scruffy::Layers::Line.new(:points => [100, 200, 300]) ],
                 :default_type => :average,
                 :renderer => blank_renderer,
                 :marker_transformer => Scruffy::Transformer::Currency.new,
                 :point_markers => ['One Hundred', 'Two Hundred', 'Three Hundred']}
                 
      @graph = Scruffy::Graph.new(options)

      @graph.title.should_equal options[:title]
      @graph.theme.should_equal options[:theme]
      @graph.layers.should_equal options[:layers]
      @graph.default_type.should_equal options[:default_type]
      @graph.renderer.should_equal options[:renderer]
      @graph.marker_transformer.should_equal options[:marker_transformer]
      @graph.point_markers.should_equal options[:point_markers]
  end
end

context "A fully populated Graph" do
  setup do
    FileUtils.rm_f File.dirname(__FILE__) + '/*.png'
    FileUtils.rm_f File.dirname(__FILE__) + '/*.jpg'

    @graph = Scruffy::Graph.new :title => 'Test Graph'
    @graph << Scruffy::Layers::AllSmiles.new(:title => 'Smiles', :points => [100, 200, 300])
    @graph << Scruffy::Layers::Area.new(:title => 'Area', :points => [100, 200, 300])
    @graph << Scruffy::Layers::Bar.new(:title => 'Bar', :points => [100, 200, 300])
    @graph << Scruffy::Layers::Line.new(:title => 'Line', :points => [100, 200, 300])
    @graph << Scruffy::Layers::Average.new(:title => 'Average', :points => @graph.layers)    
  end
  
  specify "should render to SVG" do
    @graph.render(:width => 800).should_be_instance_of?(String)
  end
  
  specify "should rasterize to PNG" do
    lambda {
      @graph.render(:width => 800, :as => 'PNG', :to => File.dirname(__FILE__) + '/test_graph.png')
    }.should_not_raise
  end

  specify "should rasterize to JPG" do
    lambda {
      @graph.render(:width => 800, :as => 'JPG', :to => File.dirname(__FILE__) + '/test_graph.jpg')
    }.should_not_raise
  end
end
  