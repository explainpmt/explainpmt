require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  
  context "on GET to :new" do
    context "when already logged in" do
      setup do
        login_as :admin
        get :new
      end
      
      should respond_with(:redirect)
    end
    
    context "when not logged in" do
      setup do
        get :new
      end
      
      should assign_to(:user_session)
      should respond_with(:success)
      should_not set_the_flash
    end
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        u = users(:admin)
        post :create, :user_session => { :login => u.login, :password => "testing" }
      end
      
      should respond_with(:redirect)
    end
    
    context "with invalid params" do
      setup do
        post :create, :user_session => { :login => nil, :password => "testing" }
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/problem/)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      delete :destroy
    end
    
    should respond_with(:redirect)
  end
  
end
