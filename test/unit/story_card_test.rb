require File.dirname(__FILE__) + '/../test_helper'

class StoryCardTest < Test::Unit::TestCase
  fixtures :story_cards

  def setup
    @story_card = StoryCard.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of StoryCard,  @story_card
  end
end
