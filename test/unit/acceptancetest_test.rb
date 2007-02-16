require File.dirname(__FILE__) + '/../test_helper'

class AcceptancetestTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  
  def setup
    @project_one = Project.find 1
    @at_one = Acceptancetest.find 1
    @at_two = Acceptancetest.find 2
    @story_one = Story.find 1
  end

  def test_name_validation
    assert @at_one.valid?
    @at_one.name = nil
    assert !@at_one.valid?
    assert_not_nil @at_one.errors[:name]
  end
  
  def test_max_name_on_acceptance
    name = ''
    name = (0..256).inject{name += "x" } 
    acceptance = Acceptancetest.new
    acceptance.name = name
    assert !acceptance.valid?
    assert_not_nil acceptance.errors[:name]
  end
end
