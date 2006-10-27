require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < Test::Unit::TestCase
  fixtures :releases
  
  def test_default
    assert_kind_of Release, releases(:first)
  end
  
  def test_same_release_date
    release = Release.new(:name => 'Test Name', :goal => 'Test Goal', :release_date => '2008-02-02', :project_id => 1)
    assert_equal true, release.valid?
    
    release = Release.new(:name => 'Test Name', :goal => 'Test Goal', :release_date => '2008-02-01', :project_id => 1)
    assert_equal false, release.valid?
  end
  
end
