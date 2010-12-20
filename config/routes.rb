Explainpmt::Application.routes.draw do
  
  root :to => "dashboard#index"
  
  resource :dashboard
  resource :user_session
  
  match 'login', :to => 'user_sessions#new', :as => "login"
  match 'logout', :to => 'user_sessions#destroy', :as => "logout"
  
  resources :projects do
    member do
      get :xml_export
      get :audits
      get :team
      get :add_users
      post :update_users
    end
    
    resource :dashboard
    
    resources :acceptance_tests do
      member do
        get :clone_acceptance
      end
      collection do
        get :export
        post :assign
      end
    end
    resources :releases do
      member do
        get :select_stories
        post :assign_stories
        post :remove_stories
      end
      
      resources :stories
    end
    
    resources :initiatives
    
    ## TODO => simiplify the stories routes, too many.
    
    resources :stories do
      member do
        get :audit
        put :take_ownership
        put :release_ownership
        get :assign_ownership
        post :assign
        put :clone_story
        put :move_up
        put :move_down
        get :edit_numeric_priority
        put :set_numeric_priority
      end
      
      collection do
        get :search
        get :all
        get :cancelled
        get :export
        get :export_tasks
        get :bulk_create
        post :create_many
      end
      
      resources :tasks do
        member do
          get :release_ownership
        end
      end
      resources :acceptance_tests
    end
    
    resources :milestones do
      collection do
        get :show_all
        get :show_recent
      end
    end
    
    resources :iterations do
      member do
        get :allocation
        get :select_stories
        post :assign_stories
        get :export
        get :export_tasks
      end
      collection do
        post :move_stories
      end
      
      resources :stories
    end
  end
  resources :users
  
end
