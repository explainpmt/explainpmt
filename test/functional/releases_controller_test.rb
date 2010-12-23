require 'test_helper'

class ReleasesControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:releases)
    should respond_with(:success)
  end
  
  context "on GET to :show" do
    setup do
      get :show, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:release)
    should assign_to(:num_non_estimated_stories)
    should assign_to(:release_points_completed)
    should assign_to(:release_points_non_completed)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:release)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:release)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => @project.id, :release => valid_release_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/created/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => @project.id, :release => valid_release_params.merge({ :name => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @release = Release.create(valid_release_params)
        put :update, :project_id => @project.id, :release => { :name => "changin names" }, :id => @release.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/updated/)
    end
    
    context "with invalid params" do
      setup do
        @release = Release.create(valid_release_params)
        put :update, :project_id => @project.id, :release => { :name => nil }, :id => @release.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/name/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @release = releases(:release_one)
      delete :destroy, :project_id => @project.id, :id => @release.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_release_params(opts={})
    opts.reverse_merge({
      :name => "nifty release",
      :description => "word to big bird",
      :date => Date.today+3.months
    })
  end
  
end
