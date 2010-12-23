require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  
  setup do
    login_as :admin
    @project = Project.first
  end
  
  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end
    
    should assign_to(:stories)
    should respond_with(:success)
  end
  
  context "on GET to :show" do
    setup do
      get :show, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:story)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:story)
  end
  
  context "on GET to :edit" do
    setup do
      get :edit, :id => 1, :project_id => @project.id
    end
    
    should assign_to(:story)
  end
  
  context "on POST to :create" do
    context "with valid params" do
      setup do
        post :create, :project_id => @project.id, :story => valid_story_params
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/saved/)
    end
    
    context "with invalid params" do
      setup do
        post :create, :project_id => @project.id, :story => valid_story_params.merge({ :title => nil })
      end
      
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to(/title/i)
    end
  end
  
  context "on PUT to :update" do
    context "with valid params" do
      setup do
        @story = Story.create(valid_story_params)
        put :update, :project_id => @project.id, :story => { :title => "changin names" }, :id => @story.to_param
      end
    
      should respond_with(:redirect)
      should set_the_flash.to(/saved/)
    end
    
    context "with invalid params" do
      setup do
        @story = Story.create(valid_story_params)
        put :update, :project_id => @project.id, :story => { :title => nil }, :id => @story.to_param
      end
      
      should respond_with(:success)
      should render_template(:edit)
      should set_the_flash.to(/title/i)
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @story = stories(:story_one)
      delete :destroy, :project_id => @project.id, :id => @story.to_param
    end
    
    should respond_with(:redirect)
    should set_the_flash.to(/deleted/)
  end
  
  protected
  
  def valid_story_params(opts={})
    opts.reverse_merge({
      :title => "nifty story",
      :description => "word to big bird",
      :project_id => 1,
      :points => 2
    })
  end
  
end
