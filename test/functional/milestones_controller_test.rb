require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:future)
    should assign_to(:recent)
    should respond_with(:success)
  end
  
  context "on GET to :show" do
    setup do
      get :show, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:milestone)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:milestone)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:milestone)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => @project.id, :milestone => valid_milestone_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => @project.id, :milestone => valid_milestone_params.merge({ :name => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @milestone = Milestone.create(valid_milestone_params)
        put :update, :project_id => @project.id, :milestone => { :name => "changin names" }, :id => @milestone.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @milestone = Milestone.create(valid_milestone_params)
        put :update, :project_id => @project.id, :milestone => { :name => nil }, :id => @milestone.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @milestone = milestones(:milestone_one)
      delete :destroy, :project_id => @project.id, :id => @milestone.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_milestone_params(opts={})
    opts.reverse_merge({
      :name => "nifty milestone",
      :description => "word to big bird",
      :date => Date.today+3.months
    })
  end
  
end
