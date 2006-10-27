require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < Test::Unit::TestCase
  fixtures :iterations, :projects
  def setup
    @project_one = Project.find 1
    @iteration_one = Iteration.find 1
  end
  
  def test_stop_date
    14.times do |i|
      @iteration_one.length = i + 1
      assert_equal @iteration_one.start_date + i, @iteration_one.stop_date
    end
  end

  def test_total_points
    @iteration_one.stories.clear
    4.times do |i|
      @iteration_one.stories.create('title' => "Test #{i}",
                                    'status' => Story::Status::New,
                                    'points' => '3')
    end
    assert_equal 12, @iteration_one.total_points
  end

  def test_remaining_resources
    test_total_points
    @iteration_one.budget = @iteration_one.total_points + 5
    assert_equal 5, @iteration_one.remaining_resources
  end

  def test_completed_points
    test_total_points
    @iteration_one.stories.create('title' => "Test Completed",
                                  'status' => Story::Status::Complete,
                                  'points' => 4)
    assert_equal 4, @iteration_one.completed_points
  end

  def test_remaining_points
    test_total_points
    test_completed_points
    assert_equal(
      @iteration_one.total_points - @iteration_one.completed_points,
      @iteration_one.remaining_points
    )
  end

  def test_iteration_id_of_stories_set_to_null_when_iteration_deleted
    story = @iteration_one.stories.create('title' => 'Test Delete Iteration',
                                          'status' => Story::Status::New,
                                          'points' => 3)
    assert_equal @iteration_one, story.iteration
    @iteration_one.destroy
    assert_nil story.iteration(true) # true arg specified to reload association
  end

  def test_iterations_not_allowed_to_overlap
    Iteration.destroy_all
    iteration1 = Iteration.new('start_date' => Date.today, 'length' => 10)
    iteration1.project = @project_one
    assert iteration1.save
    iteration2 = Iteration.new('start_date' => Date.today - 5, 'length' => 10)
    iteration2.project = @project_one
    assert !iteration2.save
    assert iteration2.errors.on('start_date')
    iteration2.start_date = Date.today + 5
    assert !iteration2.save
    assert iteration2.errors.on('start_date')
    iteration2.start_date = Date.today
    assert !iteration2.save
    assert iteration2.errors.on('start_date')
    iteration2.start_date = Date.today + 1
    iteration2.length = 5
    assert !iteration2.save
    assert iteration2.errors.on('start_date')
    iteration2.start_date = Date.today - 1
    iteration2.length = 12
    assert !iteration2.save
    assert iteration2.errors.on('start_date')
  end

  def test_iteration_must_belong_to_project
    Iteration.destroy_all
    iteration = Iteration.new('start_date' => Date.today, 'length' => 10)
    assert !iteration.save
    assert iteration.errors.on_base
    iteration.project = @project_one
    assert iteration.save
  end
end