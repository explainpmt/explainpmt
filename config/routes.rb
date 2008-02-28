ActionController::Routing::Routes.draw do |map|
map.home '', :controller => 'users', :action => 'login'
map.resources :users, :collection => { :login => :get, :authenticate => :post, :logout => :get }
map.resources :dashboards

map.resources :projects, :member => {:audits => :get} do |project|
  project.resources :acceptancetests, :member => {:clone_acceptance => :get}, :collection => {:export => :get}
  project.resource :dashboard
  project.resources :users
  project.resources :releases
  project.resources :initiatives
  project.resources :stories,  :member => {:audit => :get}, :collection => {:move_acceptancetests => :post} do |story|
    story.resources :tasks
    story.resources :acceptancetests
  end
  project.resources :milestones, :collection => {:show_all => :get, :show_recent => :get}
  project.resources :iterations, :member => {:allocation => :get}, :collection => {:move_stories => :post}
end


# Install the default route as the lowest priority.
map.connect ':controller/:action/:id'
end
