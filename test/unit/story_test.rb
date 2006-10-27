##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################


require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES

  def setup
    @user_one = User.find 1
    @story_one = stories( :first )
    @project_one = Project.find 1
    @sub_project_one = sub_projects( :first )
    @sub_project_two = sub_projects( :second )
    @sub_project_three = sub_projects( :third )
    @iteration_one = Iteration.find 1
  end
  
  def test_sub_project_association
    assert_equal @sub_project_one, @story_one.sub_project
  end
  
  def test_sub_project_must_be_part_of_storys_main_project
    assert_raises( SubProject::ProjectMismatchError ) do
      @story_one.sub_project = @sub_project_three
      @story_one.save
    end
    
    assert_nothing_raised do
      @story_one.sub_project = @sub_project_two
      @story_one.save
    end
  end
  
  def test_status_collection
    assert_equal(
      [ Story::Status::New, Story::Status::Defined, Story::Status::InProgress,
        Story::Status::Rejected, Story::Status::Blocked,
        Story::Status::Complete, Story::Status::Accepted,
        Story::Status::Cancelled ],
      Story::Statuses
    )
  end

  def test_value_collection
    assert_equal(
      [ Story::Value::High, Story::Value::MedHigh,
        Story::Value::Medium, Story::Value::MedLow, Story::Value::Low,
        Story::Value::NA ],
      Story::Values
    )
  end

  def test_risk_collection
    assert_equal(
      [ Story::Risk::High, Story::Risk::Normal, Story::Risk::Low ],
      Story::Risks
    )
  end

  def test_status_default_new
    story = Story.new
    assert_equal Story::Status::New, story.status
  end

  def test_value_default_na
    story = Story.new
    assert_equal Story::Value::NA, story.value
  end

  def test_risk_default_na
    story = Story.new
    assert_equal Story::Risk::Normal, story.risk
  end

  def test_return_ids_for_aggregations
    story = Story.new
    story.return_ids_for_aggregations
    assert_equal Story::Status::New.order, story.status
    assert_equal Story::Value::NA.order, story.value
    assert_equal Story::Risk::Normal.order, story.risk
  end

  def test_scid_increments_properly
    current_scid = @project_one.stories.sort{ |a,b| a.scid <=> b.scid }.
      last.scid
    story = @project_one.stories.create :title => 'A Story Card'
    assert_equal current_scid + 1, story.scid

    project_two = Project.find 2
    story = project_two.stories.create :title => 'Another Story Card'
    assert_equal 1, story.scid
  end

  def test_owner_set_to_nil_when_iteration_set_to_nil
    story = Story.find 1
    assert story.owner = User.find( 1 )
    story.iteration = nil
    story.save
    assert_nil story.owner
  end

  def test_status_set_to_defined_when_information_complete
    story = @project_one.stories.create('title' => 'Test Story')
    assert_equal Story::Status::New, story.status
    story.risk = Story::Risk::Low
    story.value = Story::Value::Low
    story.points = 2
    story.save
    assert_equal Story::Status::Defined, story.status
    story.status = Story::Status::InProgress
    story.save
    assert_equal Story::Status::InProgress, story.status
    story.status = Story::Status::New
    story.save
    assert_equal Story::Status::Defined, story.status
  end

  def test_status_can_only_be_new_or_cancelled_if_info_incomplete
    story = @project_one.stories.create('title' => 'Test Story')
    story.save
    assert_equal Story::Status::New, story.status
    [ Story::Status::Defined, Story::Status::InProgress, Story::Status::Blocked,
      Story::Status::Complete, Story::Status::Accepted,
      Story::Status::Rejected ].each do |stat|
      story.status = stat
      assert !story.save
      assert story.errors.on(:status)
    end
    story.status = Story::Status::Cancelled
    assert story.save
    story.status = Story::Status::New
    assert story.save
  end

  def test_only_defined_stories_can_be_added_to_an_iteration
    story = @project_one.stories.create('title' => 'Test Story')
    assert_equal Story::Status::New, story.status
    story.iteration = @iteration_one
    assert !story.save
    assert story.errors.on(:iteration)
    story.value = Story::Value::High
    story.risk = Story::Risk::High
    story.points = 1
    story.description = 'description'
    [ Story::Status::Defined, Story::Status::InProgress,
      Story::Status::Complete, Story::Status::Blocked, Story::Status::Accepted,
      Story::Status::Rejected ].each do |stat|
      story.status = stat
      assert story.save
    end
    story.status = Story::Status::Cancelled
    assert story.save
    assert !story.has_iteration?
  end

  def test_status_set_to_in_progress_when_taken_by_user_if_status_is_defined
    story = @project_one.stories.create('title' => 'Test Story')
    story.value = Story::Value::Low
    story.risk = Story::Risk::Low
    story.points = 1
    story.description = 'description'
    story.save
    @iteration_one.stories << story
    assert_equal Story::Status::Defined, story.status
    story.owner = @user_one
    story.save or fail
    assert_equal Story::Status::InProgress, story.status
  end
  
  def test_title_validations
    story = Story.new
    story.title = '_' * 255
    story.valid?
    assert_nil story.errors[:title]
    
    # title validation must throw an error when title.length > 255
    # to support postgreSQL (mySQL truncates a value when it's longer
    # than defined in the DB, but postgreSQL dies)
    story.title = '_' * 256
    story.valid?
    assert_not_nil story.errors[:title]
  end
  
  def test_points_validations
    story = Story.new
    
    for valid_value in [nil, 1, 99]
      story.points = valid_value
      story.valid?
      assert_nil story.errors[:points]
    end
    
    for invalid_value in [-99, -1, 0]
      story.points = invalid_value
      story.valid?
      assert_not_nil story.errors[:points]
    end
  end
end

class StoryValueTest < Test::Unit::TestCase
  def setup
    @values = []
    5.times do |i|
      @values << Story::Value.new(i + 1)
    end
  end

  def test_order
    @values.each_with_index do |p,i|
      i += 1
      assert_equal i, p.order
    end
  end

  def test_name
    @values.each_with_index do |p,i|
      i += 1
      case i
      when 1
        name = 'High'
      when 2
        name = 'Med-High'
      when 3
        name = 'Medium'
      when 4
        name = 'Med-Low'
      when 5
        name = 'Low'
      when 6
        name = ''
      end
      assert_equal name, p.name
    end
  end

  def test_to_s
    @values.each do |p|
      assert_equal p.name, p.to_s
    end
  end

  def test_invalid_order
    assert_raise(Story::Value::InvalidOrder) { Story::Value.new(7) }
  end

  def test_constants
    assert_equal Story::Value.new(1), Story::Value::High
    assert_equal Story::Value.new(2), Story::Value::MedHigh
    assert_equal Story::Value.new(3), Story::Value::Medium
    assert_equal Story::Value.new(4), Story::Value::MedLow
    assert_equal Story::Value.new(5), Story::Value::Low
    assert_equal Story::Value.new(6), Story::Value::NA
  end
end

class StoryRiskTest < Test::Unit::TestCase
  def setup
    @risks = []
    3.times do |i|
      @risks << Story::Risk.new(i + 1)
    end
  end

  def test_order
    @risks.each_with_index do |r,i|
      assert_equal i + 1, r.order
    end
  end

  def test_name
    @risks.each_with_index do |r,i|
      i += 1
      case i
      when 1
        name = 'High'
      when 2
        name = 'Normal'
      when 3
        name = 'Low'
      end
      assert_equal name, r.name
    end
  end

  def test_to_s
    @risks.each do |r|
      assert_equal r.name, r.to_s
    end
  end

  def test_invalid_order
    assert_raise(Story::Risk::InvalidOrder) { Story::Risk.new(5) }
  end

  def test_constants
    assert_equal Story::Risk.new(1), Story::Risk::High
    assert_equal Story::Risk.new(2), Story::Risk::Normal
    assert_equal Story::Risk.new(3), Story::Risk::Low
  end
end

class StoryStatusTest < Test::Unit::TestCase
  def setup
    @statuses = []
    8.times do |i|
      @statuses << Story::Status.new(i + 1)
    end
  end
  
  def test_order
    @statuses.each_with_index do |s,i|
      i += 1
      assert_equal i, s.order
    end
  end

  def test_name
    @statuses.each_with_index do |s,i|
      i += 1
      case i
      when 1
        name = 'New'
      when 2
        name = 'Defined'
      when 3
        name = 'In Progress'
      when 4
        name = 'Rejected'
      when 5
        name = 'Blocked'
      when 6
        name = 'Complete'
      when 7
        name = 'Accepted'
      when 8
        name = 'Cancelled'
      end
      assert_equal name, s.name
    end
  end

  def test_to_s
    @statuses.each do |s|
      assert_equal s.name, s.to_s
    end
  end

  def test_complete?
    @statuses.each_with_index do |s,i|
      i += 1
      case i
      when 6,7
        assert s.complete?
      else
        assert !s.complete?
      end
    end
  end

  def test_closed?
    @statuses.each_with_index do |s,i|
      i += 1
      case i
      when 7,8
        assert s.closed?
      else
        assert !s.closed?
      end
    end
  end

  def test_invalid_order
    assert_raise(Story::Status::InvalidOrder) { Story::Status.new(9) }
  end

  def test_constants
    assert_equal Story::Status.new(1), Story::Status::New
    assert_equal Story::Status.new(2), Story::Status::Defined
    assert_equal Story::Status.new(3), Story::Status::InProgress
    assert_equal Story::Status.new(4), Story::Status::Rejected
    assert_equal Story::Status.new(5), Story::Status::Blocked
    assert_equal Story::Status.new(6), Story::Status::Complete
    assert_equal Story::Status.new(7), Story::Status::Accepted
    assert_equal Story::Status.new(8), Story::Status::Cancelled
  end
end
