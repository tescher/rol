Rails.application.routes.draw do

  get 'settings/edit'
  patch 'settings/update'

  root 'static_pages#home'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  resources :pending_volunteers do
    member do
      get 'match'
    end
  end
  resources :users
  resources :volunteers do
    collection do
      get 'search'
      get 'import' => 'volunteers#import_form'
      post 'import' => 'volunteers#import'
    end
    member do
      get 'address_check'
      get 'donations' => 'volunteers#donations'
      post 'merge'
    end
  end
  resources :organizations do
    collection do
      get 'search'
      get 'import' => 'organizations#import_form'
      post 'import' => 'organizations#import'
    end
    member do
      get 'address_check'
      get 'donations' => 'organizations#donations'
    end
  end
  resources :workdays do
    collection do
      get 'search'
      get 'report'
      get 'workday_summary'
      get 'import' => 'workdays#import_form'
      post 'import' => 'workdays#import'
    end
    member do
      get 'add_participants'
    end
  end

  get 'workday_volunteers/import' => 'workday_volunteers#import_form'
  post 'workday_volunteers/import' => 'workday_volunteers#import', as: :import_workday_volunteers

  resources :donations do
    collection do
      get 'report'
      get 'import' => 'donations#import_form'
      post 'import' => 'donations#import'
      get 'donation_summary'
    end
  end

  resources :interests
  resources :interest_categories

  resources :projects do
    collection do
      get 'import' => 'projects#import_form'
      post 'import' => 'projects#import'
    end
  end

  resources :organization_types
  resources :donation_types
  resources :contact_types


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
