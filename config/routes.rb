ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

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
