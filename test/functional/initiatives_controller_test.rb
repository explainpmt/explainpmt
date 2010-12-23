require 'test_helper'

class InitiativesControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:initiatives)
    should respond_with(:success)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:initiative)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:initiative)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => @project.id, :initiative => valid_initiative_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => @project.id, :initiative => valid_initiative_params.merge({ :name => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @initiative = Initiative.create(valid_initiative_params)
        put :update, :project_id => @project.id, :initiative => { :name => "changin names" }, :id => @initiative.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @initiative = Initiative.create(valid_initiative_params)
        put :update, :project_id => @project.id, :initiative => { :name => nil }, :id => @initiative.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @initiative = initiatives(:big_initiative)
      delete :destroy, :project_id => @project.id, :id => @initiative.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_initiative_params(opts={})
    opts.reverse_merge({
      :name => "nifty initiative",
      :start_date => Date.today+1.month,
      :end_date => Date.today+3.months,
      :project_id => 1
    })
  end
  
end
