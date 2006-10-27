require File.expand_path( File.dirname( __FILE__ ) + '/../test_helper' )

class RoutingTest < Test::Unit::TestCase
  def test_root_points_to_main_dashboard
    assert_routing '', :controller => 'main', :action => 'dashboard'
  end
end
