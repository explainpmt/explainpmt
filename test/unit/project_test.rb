require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects, :users, :projects_users

  def test_users_relationship
    user_1, user_2, user_3 = User.find :all, :order => 'id', :limit => 3
    project_1, project_2 = Project.find :all, :order => 'id', :limit => 2

    assert_equal [ user_1, user_2 ], project_1.users.sort { |u1,u2| u1.id <=> u2.id }
    assert_equal [ user_2, user_3 ], project_2.users.sort { |u1,u2| u1.id <=> u2.id }
  end
end
