require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @current_user = users(:admin)
  end
  
  context "on GET to :index" do
    setup do
      get :index
    end
    
    should assign_to(:users)
    should respond_with(:success)
    should render_template(:index)
    should_not set_the_flash
  end
  
  context "on GET to :new" do
    setup do
      get :new
    end
    
    should assign_to(:user)
    
    should respond_with(:success)
    should render_template(:new)
    should_not set_the_flash
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1
    end
    
    should assign_to(:user)
    
    should respond_with(:success)
    should render_template(:edit)
    should_not set_the_flash
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :user => valid_user_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :user => valid_user_params.merge({ :email => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/email/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @user = User.create(valid_user_params)
        put :update, :user => { :email => "bob@lawblaw.com" }, :id => @user.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @user = User.create(valid_user_params)
        put :update, :user => { :email => nil }, :id => @user.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/email/i)
    end
  end
  
  # context "on DELETE to :destroy" do
  #   setup do
  #     @user = users(:david)
  #     delete :destroy, :id => @user.to_param
  #   end
  #   
  #   should respond_with(:redirect)
  #   should set_the_flash.to(/deleted/)
  # end
  
end
