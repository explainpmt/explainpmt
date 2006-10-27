ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  ALL_FIXTURES = [ :iterations, :milestones, :projects_users, :projects,
    :stories, :users ]

  private
  def create_common_fixtures(*fixture_names)
    fixture_names.each do |name|
      self.send("fixture_#{name}".to_sym)
    end
  end

  def fixture_admin
    @admin = User.create('username' => 'admin', 'password' => 'adminpass',
                         'email' => 'admin@example.com', 'admin' => 1,
                         'first_name' => 'Admin', 'last_name' => 'User')
  end

  def fixture_user_one
    @user_one = User.create('username' => 'user_one',
                            'password' => 'user_onepassword',
                            'email' => 'user_one@example.com',
                            'first_name' => 'User', 'last_name' => 'One',
                            'admin' => 0)
  end

  def fixture_project_one
    @project_one = Project.create('name' => 'Project One')
  end

  def fixture_project_two
    @project_two = Project.create('name' => 'Project Two')
  end

  def fixture_story_one
    @story_one = Story.create('title' => 'Story One',
                              'description' => 'Story One',
                              'priority' => Story::Priority::High,
                              'risk' => Story::Risk::High,
                              'points' => 1,
                              'status' => Story::Status::Defined)
  end

  def fixture_story_two
    @story_two = Story.create('title' => 'Story Two',
                              'description' => 'Story Two',
                              'priority' => Story::Priority::High,
                              'risk' => Story::Risk::High,
                              'points' => 1,
                              'status' => Story::Status::Defined)
  end

  def fixture_iteration_one
    @iteration_one = Iteration.create('start_date' => Date.today,
                                      'length' => 14)
  end

  def fixture_past_milestone1
    @past_milestone1 = @project_one.milestones.create('name' => 'Milestone1',
                                                      'date' => Date.today - 365)
  end

  def fixture_past_milestone2
    @past_milestone2 = @project_one.milestones.create('name' => 'Milestone1',
                                                      'date' => Date.today - 15)
  end

  def fixture_recent_milestone1
    @recent_milestone1 = @project_one.milestones.create('name' => 'Milestone1',
                                                        'date' => Date.today - 14)
  end

  def fixture_recent_milestone2
    @recent_milestone2 = @project_one.milestones.create('name' => 'Milestone1',
                                                        'date' => Date.today - 1)
  end

  def fixture_future_milestone1
    @future_milestone1 = @project_one.milestones.create('name' => 'Milestone1',
                                                        'date' => Date.today)
  end

  def fixture_future_milestone2
    @future_milestone2 = @project_one.milestones.create('name' => 'Milestone1',
                                                        'date' => Date.today + 365)
  end
end
