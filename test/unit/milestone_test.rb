require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES

  def setup
    @past_milestone1 = Milestone.find 1
    @past_milestone2 = Milestone.find 2
    @recent_milestone1 = Milestone.find 3
    @recent_milestone2 = Milestone.find 4
    @future_milestone1 = Milestone.find 5
    @future_milestone2 = Milestone.find 6
  end
  
  def test_future_eh
    assert !@past_milestone1.future?
    assert !@past_milestone2.future?
    assert !@recent_milestone1.future?
    assert !@recent_milestone2.future?
    assert @future_milestone1.future?
    assert @future_milestone2.future?
  end
  
  def test_recent_eh
    assert !@past_milestone1.recent?
    assert !@past_milestone2.recent?
    assert @recent_milestone1.recent?
    assert @recent_milestone2.recent?
    assert !@future_milestone1.recent?
    assert !@future_milestone2.recent?
  end
  
  def test_past_eh
    assert @past_milestone1.past?
    assert @past_milestone2.past?
    assert @recent_milestone1.past?
    assert @recent_milestone2.past?
    assert !@future_milestone1.past?
    assert !@future_milestone2.past?
  end
end
