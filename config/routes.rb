KatApp::Application.routes.draw do

  resources :users
  resources :katibeen
  resources :performance
  resources :data
  resources :analytics

  #Static pages
  root :to => "katibeen#home"
  get "katibeen/home"
  match "/about" => "katibeen#about", :as => "about"
  match "/welcome" => "katibeen#home"
  

  #User signup and unsub
  post "users/signup"
  match "/welcome/:url" => "users#welcome"
  match "/unsubscribe/:url" => "users#unsubscribe"
  
  #Data controller
  match "/day_data/:url/:prayer_day_id" => "data#requestData"
  match "/katibeen/submitDayData" => "data#submitDayData", :as => "submitDayData"

  #Performance controller
  match "/:url" => "performance#performance", :as => "performance"
  match "widgetData/:url" => "performance#widgetData"
  match "/dash/:url"   =>  "performance#temporary"

  #Analytics
  match "/analytics" => "analytics#get"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
