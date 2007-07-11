ActionController::Routing::Routes.draw do |map|

map.resources :users,
  :collection => { :login => :get, :authenticate => :post, :logout => :get }

map.connect ':controller/:action/:id', :controller => 'dashboard'

map.connect 'project/:project_id/stories',
            :controller => 'stories', :action => 'index'
            
map.connect 'project/:project_id/stories/show_cancelled',
            :controller => 'stories', :action => 'index', :show_cancelled => 1
            
map.connect 'project/:project_id/:controller/:action/:id',
            :controller => 'dashboard'

# Install the default route as the lowest priority.
map.connect ':controller/:action/:id'
end
