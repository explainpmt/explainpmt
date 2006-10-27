require File.dirname(__FILE__) + '/../test_helper'

class StoryCardTest < Test::Unit::TestCase
  fixtures :users, :projects, :projects_users, :story_cards

  def setup
    @project_one = Project.find 1
    @project_two = Project.find 2
  end
  
  def test_project_relationship
    sca, scb, scc, scd = StoryCard.find :all, :order => 'id', :limit => 4
    p1, p2 = Project.find :all, :order => 'id', :limit => 2

    assert_equal p1, sca.project
    assert_equal p1, scb.project
    assert_equal p2, scc.project
    assert_equal p2, scd.project
  end

  def test_user_relationship
    sca, scb, scc, scd = StoryCard.find :all, :order => 'id', :limit => 4
    ua, ub, uc = User.find :all, :order => 'id', :limit => 3

    assert_equal ua, sca.user
    assert_equal ub, scb.user
    assert_equal ub, scc.user
    assert_equal uc, scd.user
  end
  
  # Start CRUD
  def test_create_story_card
    new_story_card = StoryCard.new
    new_story_card.id = 5
    new_story_card.name = 'New Story Card'
    new_story_card.project = @project_one
    
    assert new_story_card.save
    assert_equal 5, StoryCard.find(5).id
    assert_equal 'New Story Card', StoryCard.find(5).name
    assert_equal 3, StoryCard.find(5).scid
  end
  
  def test_read_story_card
    story_card = StoryCard.find 1
    assert_equal "Story Card A", story_card.name
    assert_equal 4, story_card.points
  end
  # End CRUD
  
  def test_presence_of_validation
    story_card = StoryCard.new
    assert !story_card.save
    story_card.project = @project_one
    assert !story_card.save
    story_card.name = ''
    assert !story_card.save
    story_card.name = ' '
    assert !story_card.save
    story_card.name = 'New Story Card'
    assert story_card.save
  end

  def test_uniqueness_of_story_card_id_within_project
    story_card_one = StoryCard.new
    story_card_one.name = 'New Story Card'
    story_card_one.project = @project_one
    story_card_one.save
    
    assert_equal 3, story_card_one.scid

    story_card_two = StoryCard.new
    story_card_two.name = 'New Story Card'
    story_card_two.project = @project_two
    story_card_two.save
    
    assert_equal 3, story_card_two.scid
    
    story_card_three = StoryCard.new
    story_card_three.name = 'New Story Card'
    story_card_three.project = @project_one
    story_card_three.save
    
    assert_not_equal story_card_one.scid, story_card_three.scid
    
    story_card_three.scid = story_card_one.scid
    assert !story_card_three.save
    
    story_card_three = StoryCard.find story_card_three.id
    assert_not_equal story_card_one.scid, story_card_three.scid
  end
  
  def test_numericality_of_points
    story_card = StoryCard.new
    story_card.name = 'New Story Card'
    story_card.project = @project_one
    story_card.points = 'Just a string'
    
    assert !story_card.save
    
    story_card.points = '2 points'
    assert !story_card.save
    
    story_card.points = '2'
    assert story_card.save
    
    story_card.points = 2
    assert story_card.save
    
    # Points is not a required field, so it is valid if nil.
    story_card.points = ''
    assert story_card.save
  end
  
  def test_default_values_for_new_story_card
    story_card = StoryCard.new
    story_card.name = 'New Story Card'
    story_card.project = @project_one
    story_card.save
    
    assert_equal 1, story_card.status
    assert_equal 0, story_card.risk
    
    story_card.status = 2
    story_card.risk = 3
    story_card.save
    
    assert_equal 2, story_card.status
    assert_equal 3, story_card.risk
  end
end
