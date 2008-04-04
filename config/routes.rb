ActionController::Routing::Routes.draw do |map|
map.home '', :controller => 'users', :action => 'login'
map.resources :users, :collection => { :login => :get, :authenticate => :post, :logout => :get }
map.resources :dashboards
map.resources :errors
map.resources :projects, :member => {:audits => :get, :team => :get, :add_users => :get, :update_users => :post} do |project|
  project.resources :acceptancetests, :member => {:clone_acceptance => :get}, :collection => {:export => :get, :assign => :post,}
  project.resource :dashboard
  project.resources :users, :member => {:remove_from_project => :put}
  project.resources :releases
  project.resources :stats
  project.resources :initiatives
  project.resources :stories,
    :member => {:audit => :get, :take_ownership => :put, :release_ownership => :put, :assign_ownership => :get, :assign => :post, :clone_story => :put,
        :move_up => :put, :move_down => :put, :edit_numeric_priority => :get, :set_numeric_priority => :put},
    :collection => {:cancelled => :get, :export => :get, :export_tasks => :get, :bulk_create => :get, :create_many => :post} do |story|
    story.resources :tasks, :member => {:take_ownership => :put, :release_ownership => :put, :assign_ownership => :get, :assign => :post}
    story.resources :acceptancetests
  end
  project.resources :milestones, :collection => {:show_all => :get, :show_recent => :get}
  project.resources :iterations,
    :member => {:allocation => :get, :select_stories => :get, :assign_stories => :post, :export => :get, :export_tasks => :get},
    :collection => {:move_stories => :post} do |iteration|
    iteration.resources :stories
  end
end


# Install the default route as the lowest priority.
map.connect ':controller/:action/:id'
end
