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
require 'dashboard_controller'

# Re-raise errors caught by the controller.
class DashboardController; def rescue_action(e) raise e end; end

class DashboardControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  def setup
    @admin = User.find 1
    @user_one = User.find 2
    @user_two = User.find 3

    @controller = DashboardController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[:current_user] = @admin
  end

  def test_authentication_required
    @request.session[:current_user] = nil
    get :index
    assert_redirected_to :controller => 'users', :action => 'login'
    assert_equal '/', session[:return_to]
    assert_equal "Please log in, and we'll send you right along.",
                 flash[:status]
  end

  def test_index_when_no_projects_exist
    Project.destroy_all
    get :index
    assert_response :success
    assert_template 'index_no_projects'
  end

  def test_index_when_regular_user_assigned_to_no_projects
    @user_one.projects.clear
    @request.session[:current_user] = @user_one
    get :index
    assert_response :success
    assert_template 'index_no_projects'
    assert_equal [], assigns(:projects)
  end

  def test_index_when_regular_user_on_multiple_project_teams
    @request.session[:current_user] = @user_one
    get :index
    assert_response :success
    assert_template 'index'
    assert_equal @user_one.projects, assigns(:projects)
  end

  def test_index_when_regular_user_on_one_project_team
    @request.session[ :current_user ] = @user_two
    get :index
    assert_redirected_to :controller => 'dashboard', :action => 'index',
      :project_id => @user_two.projects.first.id
  end

  def test_index_with_project_id
    get :index, 'project_id' => '1'
    assert_response :success
    assert_template 'project'
    assert_equal Project.find( 1 ), assigns( :project )
  end
  
  ### Regression Tests ###
  
  def test_index_when_user_has_multiple_projects_and_one_story_card_should_not_raise_error
    User.destroy_all
    Project.destroy_all
    Iteration.destroy_all
    Story.destroy_all
    
    user = User.create('username' => 'test', 'password' => 'testtest',
      'email' => 'test@example.com', 'first_name' => 'Test',
      'last_name' => 'User', 'admin' => true)
    project1 = Project.create('name' => 'Project One', 'description' => '1')
    project1.users << user
    project2 = Project.create('name' => 'Project Two', 'description' => '2')
    project2.users << user
    iteration = project1.iterations.create('start_date' => Time.now,
      'budget' => 5)
    story = project1.stories.create('title' => 'Story Card',
      'description' => 'test', 'points' => 1,
      'value' => Story::Value::High, 'risk' => Story::Risk::High)
    iteration.stories << story
    story.owner = user
    story.save
    
    @request.session[:current_user] = user
    get :index
    assert_response :success
    assert_template 'index'
  end
end
