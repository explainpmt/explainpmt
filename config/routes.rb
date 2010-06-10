ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'users', :action => 'login'
  map.resources :users, :collection => { :password_reset_confirmation => :post, :forgot => :any, :login => :get, :authenticate => :post, :logout => :get }
  map.resources :dashboards
  map.resources :errors
  map.resources :projects, :member => {:xml_export => :get, :audits => :get, :team => :get, :add_users => :get, :update_users => :post} do |project|
    project.resources :acceptancetests, :member => {:clone_acceptance => :get}, :collection => {:export => :get, :assign => :post, }
    project.resource :dashboard
    project.resources :users, :member => {:remove_from_project => :put}
    project.resources :releases, :member=>{:select_stories => :get, :assign_stories => :post, :remove_stories=>:post} do |release|
      release.resources :stories
    end
    project.resources :stats
    project.resources :initiatives
    project.resources :stories,
                      :member => {:audit => :get, :take_ownership => :put, :release_ownership => :put, :assign_ownership => :get, :assign => :post, :clone_story => :put,
                                  :move_up => :put, :move_down => :put, :edit_numeric_priority => :get, :set_numeric_priority => :put},
                      :collection => {:search => :get, :all => :get, :cancelled => :get, :export => :get, :export_tasks => :get, :bulk_create => :get, :create_many => :post} do |story|
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

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
