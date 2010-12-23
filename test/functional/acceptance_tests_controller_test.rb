require 'test_helper'

class AcceptanceTestsControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:acceptance_tests)
    should respond_with(:success)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:acceptance_test)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:acceptance_test)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => @project.id, :acceptance_test => valid_acceptance_test_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => @project.id, :acceptance_test => valid_acceptance_test_params.merge({ :name => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @acceptance_test = AcceptanceTest.create(valid_acceptance_test_params)
        put :update, :project_id => @project.id, :acceptance_test => { :name => "changin names" }, :id => @acceptance_test.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @acceptance_test = AcceptanceTest.create(valid_acceptance_test_params)
        put :update, :project_id => @project.id, :acceptance_test => { :name => nil }, :id => @acceptance_test.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @acceptance_test = acceptance_tests(:not_automated_doesnt_pass)
      delete :destroy, :project_id => @project.id, :id => @acceptance_test.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_acceptance_test_params(opts={})
    opts.reverse_merge({
      :name => "nifty acceptance_test",
      :description => "cool beans",
      :automated => 0,
      :pass => 0
    })
  end
  
end
