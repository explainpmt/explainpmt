require File.dirname(__FILE__) + '/../test_helper'
require 'acceptancetests_controller'

# Re-raise errors caught by the controller.
class AcceptancetestsController; def rescue_action(e) raise e end; end

class AcceptancetestsControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  
  def setup
    @controller = AcceptancetestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
   
    @project_one = Project.find 1
    @at_one = Acceptancetest.find 1
    @at_two = Acceptancetest.find 2
    @story_one = Story.find 1
    @request.session[:current_user] = User.find 2
  end

  def test_index
    get :index, :project_id => @project_one.id
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:list)
    assert_equal 'Acceptance Tests', assigns(:page_title)
    assert_equal @project_one.stories, assigns(:stories)
    assert_equal 2, assigns(:list).size

  end
  
  def test_clone_acceptance_with_story
    get :clone_acceptancetest, :story_id => @at_one.story_id, :id => @at_one.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns( :object )
    assert_equal @at_one.story, assigns( :story )
    assert_equal @at_one, assigns(:object)
    assert_equal 'Clone Acceptancetest', assigns(:page_title)
  end
  
  def test_clone_acceptance_without_story
    get :clone_acceptancetest, :id => @at_two.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns(:object)
    assert_nil assigns(:story)
    assert_equal @at_two, assigns(:object)
  end
  
  def test_clone_acceptance_with_existing_acceptance_in_session
    @request.session[:object] = @at_two
    get :clone_acceptancetest, :id => @at_one.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns(:object)
    assert_equal @at_two, assigns(:object)
  end
  
  def test_export
     get :export, :project_id => @project_one.id
     assert_equal 2, assigns(:list).size
     assert_template 'export'
  end
  
  def test_new_acceptance_test_for_a_story
    get :new_acceptance_for_story, :story_id => @story_one.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns(:object)
    assert assigns(:object).new_record?
  end
  
  def test_new_acceptance_test_for_story_with_existing_acceptance_in_session
    @request.session[:object] = Acceptancetest.new
    get :new_acceptance_for_story, :story_id => @story_one.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns(:object)
    assert assigns(:object).new_record?
  end
end
