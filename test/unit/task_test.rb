require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveRecord::TestCase
  
  def setup
    @task_one = Task.find 1
    @task_two = Task.find 2
    @cloned_task = @task_one.clone
  end
  
  # Replace this with your real tests.
  def test_story_association
    assert_equal @task_one.story,  Story.find( 1 ) 
  end
  
  def test_user_association
    assert_equal @task_one.owner, User.find( 1 )
  end
  
  def test_uniqueness_of_task_name
    @cloned_task.save
    assert @cloned_task.errors.on(:name)
  end
  
  def test_same_task_name_on_separate_projects
    @cloned_task.story = Story.find 2
    @cloned_task.save
    assert :success
  end
  
  def test_validate_presence_of_name
    task = Task.create
    assert task.errors.on(:name)
  end
  
  def test_task_default_completed_state
    task = Task.new
    assert !task.complete
  end
end
