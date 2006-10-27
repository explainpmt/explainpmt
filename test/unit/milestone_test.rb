require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < Test::Unit::TestCase
  fixtures :projects, :milestones

  def test_project_relationship
    assert_equal Project.find( 1 ), Milestone.find( 1 ).project
  end
end
