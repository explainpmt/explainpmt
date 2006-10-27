require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects, :users, :projects_users, :story_cards

  def setup
    @project_one = Project.find 1
    @project_two = Project.find 2
  end


  def test_users_relationship
    user_1, user_2, user_3 = User.find :all, :order => 'id', :limit => 3
    project_1, project_2 = Project.find :all, :order => 'id', :limit => 2

    assert_equal [ user_1, user_2 ], project_1.users.sort { |u1,u2| u1.id <=> u2.id }
    assert_equal [ user_2, user_3 ], project_2.users.sort { |u1,u2| u1.id <=> u2.id }
  end

  def test_story_cards_relationship
    sca, scb, scc, scd = StoryCard.find :all, :order => 'id', :limit => 4
    p1, p2 = Project.find :all, :order => 'id', :limit => 2

    assert_equal [ sca, scb ], p1.story_cards.sort { |a,b| a.id <=> b.id }
    assert_equal [ scc, scd ], p2.story_cards.sort { |a,b| a.id <=> b.id }
  end

  def test_milestones_relationship
    milestones = Milestone.find :all, :order => 'id',
      :conditions => [ 'project_id = ?', 1 ]
    project = Project.find 1
    assert_equal milestones, project.milestones.sort { |a,b| a.id <=> b.id }
  end
  
  # Start CRUD
  def test_create_project
    new_project = Project.new
    new_project.id = 3
    new_project.name = "Third Project"  
    assert new_project.save
    assert_equal 3, Project.find(3).id
    assert_equal "Third Project", Project.find(3).name
  end
  
  def test_read_project
    assert_equal "First Project", @project_one.name
    assert @project_one.id, 1
  end

  def test_update_project
    assert_equal "First Project", @project_one.name
    @project_one.name = "Changed Project"
    assert @project_one.save
    assert "Changed Project", @project_one.name
  end

  def test_destroy_project
    @project_one.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Project.find(@project_one.id) }
    @project_two.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Project.find(@project_two.id) }
  end
  # End CRUD
end

