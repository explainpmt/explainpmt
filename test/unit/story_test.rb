require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < Test::Unit::TestCase
  def setup
    Project.destroy_all
    User.destroy_all
    create_common_fixtures :user_one, :project_one, :project_two,
                           :iteration_one
    @iteration_one.project = @project_one
    @iteration_one.save
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

  def test_priority_collection
    assert_equal(
      [ Story::Priority::High, Story::Priority::MedHigh,
        Story::Priority::Medium, Story::Priority::MedLow, Story::Priority::Low,
        Story::Priority::NA ],
      Story::Priorities
    )
  end

  def test_risk_collection
    assert_equal(
      [ Story::Risk::High, Story::Risk::Medium, Story::Risk::Low,
        Story::Risk::NA ],
      Story::Risks
    )
  end

  def test_status_default_new
    story = Story.new
    assert_equal Story::Status::New, story.status
  end

  def test_priority_default_na
    story = Story.new
    assert_equal Story::Priority::NA, story.priority
  end

  def test_risk_default_na
    story = Story.new
    assert_equal Story::Risk::NA, story.risk
  end

  def test_return_ids_for_aggregations
    story = Story.new
    story.return_ids_for_aggregations
    assert_equal Story::Status::New.order, story.status
    assert_equal Story::Priority::NA.order, story.priority
    assert_equal Story::Risk::NA.order, story.risk
  end

  def test_scid_increments_properly
    story1 = @project_one.stories.create('title' => 'Story1')
    story1.save
    assert_equal 1, story1.scid
    story2 = @project_one.stories.create('title' => 'Story2')
    story2.save
    assert_equal 2, story2.scid
    story3 = @project_one.stories.create('title' => 'Story3')
    story3.save
    assert_equal 3, story3.scid
    story2.destroy
    story4 = @project_one.stories.create('title' => 'Story4')
    story4.save
    assert_equal 4, story4.scid
    story1 = @project_two.stories.create('title' => 'Story1')
    story1.save
    assert_equal 1, story1.scid
  end

  def test_owner_set_to_nil_when_iteration_set_to_nil
    @project_one.users << @user_one
    story = @iteration_one.stories.create('title' => 'Test Story')
    story.project = @project_one
    story.owner = @user_one
    story.save
    assert_equal story.iteration_id, @iteration_one.id
    story.iteration = nil
    story.save
    assert_nil story.owner
  end

  def test_status_set_to_defined_when_information_complete
    story = @project_one.stories.create('title' => 'Test Story')
    story.save
    assert_equal Story::Status::New, story.status
    story.risk = Story::Risk::Low
    story.priority = Story::Priority::Low
    story.points = 2
    story.description = "This is the story description."
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
    story.priority = Story::Priority::High
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
    story.priority = Story::Priority::Low
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
  end
end

class StoryPriorityTest < Test::Unit::TestCase
  def setup
    @priorities = []
    5.times do |i|
      @priorities << Story::Priority.new(i + 1)
    end
  end

  def test_order
    @priorities.each_with_index do |p,i|
      i += 1
      assert_equal i, p.order
    end
  end

  def test_name
    @priorities.each_with_index do |p,i|
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
    @priorities.each do |p|
      assert_equal p.name, p.to_s
    end
  end

  def test_invalid_order
    assert_raise(Story::Priority::InvalidOrder) { Story::Priority.new(7) }
  end

  def test_constants
    assert_equal Story::Priority.new(1), Story::Priority::High
    assert_equal Story::Priority.new(2), Story::Priority::MedHigh
    assert_equal Story::Priority.new(3), Story::Priority::Medium
    assert_equal Story::Priority.new(4), Story::Priority::MedLow
    assert_equal Story::Priority.new(5), Story::Priority::Low
    assert_equal Story::Priority.new(6), Story::Priority::NA
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
        name = 'Medium'
      when 3
        name = 'Low'
      when 4
        name = ''
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
    assert_equal Story::Risk.new(2), Story::Risk::Medium
    assert_equal Story::Risk.new(3), Story::Risk::Low
    assert_equal Story::Risk.new(4), Story::Risk::NA
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
