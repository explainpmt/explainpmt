require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < Test::Unit::TestCase
  fixtures :iterations, :projects, :stories
  def setup
    @project_one = Project.find 1
    @iteration_one = Iteration.find 1
  end
  
  def test_stop_date
    assert_equal @iteration_one.start_date + ( @iteration_one.length - 1 ),
      @iteration_one.stop_date
  end

  def test_total_points
    assert_equal 6, @iteration_one.total_points
  end

  def test_remaining_resources
    assert_equal 5, @iteration_one.remaining_resources
  end

  def test_completed_points
    assert_equal 3, @iteration_one.completed_points
  end

  def test_remaining_points
    assert_equal 3, @iteration_one.remaining_points
  end

  def test_iteration_id_of_stories_set_to_null_when_iteration_deleted
    @iteration_one.destroy
    assert_nil Story.find( 1 ).iteration
  end

  def test_iterations_not_allowed_to_overlap_on_same_project
    iteration_two = Iteration.find 2
    [ -1, 0, 13 ].each do |i|
      iteration_two.start_date = @iteration_one.start_date + i
      assert !iteration_two.valid?
      assert iteration_two.errors.on( :start_date )
    end
  end

  def test_iterations_allowed_to_overlap_on_different_project
    iteration_three = Iteration.find 3
    [ -1, 0, 13 ].each do |i|
      iteration_three.start_date = @iteration_one.start_date + i
      assert iteration_three.valid?
      assert_nil iteration_three.errors.on( :start_date )
    end
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