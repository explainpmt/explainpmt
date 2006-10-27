require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  def setup
    Project.destroy_all
    create_common_fixtures :project_one, :past_milestone1, :past_milestone2,
                           :recent_milestone1, :recent_milestone2,
                           :future_milestone1, :future_milestone2
  end
  
  def test_current_iteration
    assert_nil @project_one.current_iteration(true)
    assert_nil @project_one.current_iteration

    iteration = @project_one.iterations.create('start_date' => Date.today,
                                               'length' => 14)
    iteration.save
    assert_equal iteration, @project_one.current_iteration(true)
    assert_equal iteration, @project_one.current_iteration
    iteration.start_date = (Date.today - 10)
    iteration.save
    assert_equal iteration, @project_one.current_iteration(true)
    assert_equal iteration, @project_one.current_iteration
    iteration.start_date = (Date.today + 1)
    iteration.save
    assert_nil @project_one.current_iteration(true)
    assert_nil @project_one.current_iteration
  end
  
  def test_previous_iteration
    assert_nil @project_one.previous_iteration(true)
    assert_nil @project_one.previous_iteration
    iteration = @project_one.iterations.create('start_date' => (Date.today - 1),
                                               'length' => 2)
    assert_nil @project_one.previous_iteration(true)
    assert_nil @project_one.previous_iteration
    iteration.length = 1
    iteration.save
    assert_equal iteration, @project_one.previous_iteration(true)
    assert_equal iteration, @project_one.previous_iteration
    iteration2 = @project_one.iterations.create(
      'start_date' => (Date.today - 30),
      'length' => 1
    )
    @project_one.iterations.create('start_date' => Date.today, 'length' => 1)
    assert_equal iteration, @project_one.previous_iteration(true)
    assert_equal iteration, @project_one.previous_iteration
    iteration.destroy
    assert_equal iteration2, @project_one.previous_iteration(true)
    assert_equal iteration2, @project_one.previous_iteration
    iteration2.destroy
    assert_nil @project_one.previous_iteration(true)
    assert_nil @project_one.previous_iteration
  end

  def test_next_iteration
    assert_nil @project_one.next_iteration(true)
    assert_nil @project_one.next_iteration
    iteration = @project_one.iterations.create('start_date' => Date.today,
                                               'length' => 1)
    assert_nil @project_one.next_iteration(true)
    assert_nil @project_one.next_iteration
    iteration.start_date = Date.today + 1
    iteration.save
    assert_equal iteration, @project_one.next_iteration(true)
    assert_equal iteration, @project_one.next_iteration
    @project_one.iterations.create('start_date' => Date.today, 'length' => 1)
    @project_one.iterations.create('start_date' => Date.today - 1,
                                   'length' => 1)
    assert_equal iteration, @project_one.next_iteration(true)
    assert_equal iteration, @project_one.next_iteration
    iteration.destroy
    assert_nil @project_one.next_iteration(true)
    assert_nil @project_one.next_iteration
    iteration = @project_one.iterations.create(iteration.attributes)
    @project_one.iterations.create('start_date' => Date.today + 5,
                                   'length' => 1)
    assert_equal iteration, @project_one.next_iteration(true)
    assert_equal iteration, @project_one.next_iteration
  end

  def test_backlog
    assert @project_one.backlog(true).empty?
    4.times do |i|
      @project_one.stories.create('title' => "Test Backlog #{i}",
                                  'status' => Story::Status::New)
    end
    assert_equal 4, @project_one.backlog(true).size
    iteration = @project_one.iterations.create('start_date' => Date.today,
                                               'length' => 1)
    story = @project_one.stories.create('title' => "Test Backlog")
    story.priority = Story::Priority::High
    story.risk = Story::Risk::Low
    story.points = 4
    story.description = 'description'
    story.save
    assert_equal 5, @project_one.backlog(true).size
    story.iteration = iteration
    story.save
    assert_equal 4, @project_one.backlog(true).size
  end

  def test_future_iterations
    assert @project_one.future_iterations(true).empty?
    assert @project_one.future_iterations.empty?
    (-1..3).to_a.each do |i|
      @project_one.iterations.create('start_date' => Date.today + i,
                                     'length' => 1)
    end
    assert_equal 3, @project_one.future_iterations(true).size
    assert_equal 3, @project_one.future_iterations.size
  end
  
  def test_past_iterations
    assert @project_one.past_iterations(true).empty?
    assert @project_one.past_iterations.empty?
    (-3..1).to_a.each do |i|
      @project_one.iterations.create('start_date' => Date.today + i,
                                     'length' => 1)
    end
    assert_equal 3, @project_one.past_iterations(true).size
    assert_equal 3, @project_one.past_iterations.size
  end
  
  def test_future_milestones
    assert_equal [ @future_milestone1, @future_milestone2 ],
                 @project_one.future_milestones
  end
  
  def test_recent_milestones
    assert_equal [ @recent_milestone2, @recent_milestone1 ],
                 @project_one.recent_milestones
  end
  
  def test_past_milestones
    assert_equal [ @recent_milestone2, @recent_milestone1, @past_milestone2,
                   @past_milestone1 ], @project_one.past_milestones
  end
end

