require File.dirname(__FILE__) + '/../test_helper'

class StoryCardTest < Test::Unit::TestCase
  fixtures :users, :projects, :projects_users, :story_cards

  def test_project_relationship
    sca, scb, scc, scd = StoryCard.find :all, :order => 'id', :limit => 4
    p1, p2 = Project.find :all, :order => 'id', :limit => 2

    assert_equal p1, sca.project
    assert_equal p1, scb.project
    assert_equal p2, scc.project
    assert_equal p2, scd.project
  end
end
