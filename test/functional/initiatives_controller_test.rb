require File.dirname(__FILE__) + '/../test_helper'
require 'initiatives_controller'

# Re-raise errors caught by the controller.
class InitiativesController; def rescue_action(e) raise e end; end

class InitiativesControllerTest < Test::Unit::TestCase
  def setup
    @controller = InitiativesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
