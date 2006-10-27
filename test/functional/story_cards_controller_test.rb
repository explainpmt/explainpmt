require File.dirname(__FILE__) + '/../test_helper'
require 'story_cards_controller'

# Re-raise errors caught by the controller.
class StoryCardsController; def rescue_action(e) raise e end; end

class StoryCardsControllerTest < Test::Unit::TestCase
  fixtures :users, :projects, :projects_users, :story_cards

  def setup
    @controller       = StoryCardsController.new
    @request          = ActionController::TestRequest.new
    @response         = ActionController::TestResponse.new
    @user             = User.find(2)
    @project          = Project.find(1)
    @story_card       = StoryCard.find(1)
  end

  def test_show_no_auth
    get :show
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  def test_show_as_user
    @request.session[ :current_user_id ] = @user.id
    get :show, { :id => '1', :project_id => '1' }

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:story_card)
    assert assigns(:story_card).valid?
  end

  def test_new_no_auth
    get :new
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  def test_new_as_user
    @request.session[ :current_user_id ] = @user.id
    get :new, :project_id => '1'

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:story_card)
  end

  def test_create_no_auth
    get :create
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  def test_create_as_user
    @request.session[ :current_user_id ] = @user.id
    num_story_cards = StoryCard.count

    post :create, { :project_id => '1',
                    :story_card => {
                      'name' => 'New Story Card',
                      'status' => '1',
                      'priority' => '',
                      'risk' => '',
                      'points' => '',
                      'description' => '' } }

    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_equal num_story_cards + 1, StoryCard.count
  end
end
