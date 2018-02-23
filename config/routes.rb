Rails.application.routes.draw do
 
  resources :notacredits
  resources :products
  resources :nota
  resources :credits
  resources :mailings
  resources :clients
  
  resources :users
  resources :reports 
  
  
devise_for :users, skip: [:sessions]
as :user do
  get 'signin', to: 'devise/sessions#new', as: :new_user_session
  post 'signin', to: 'devise/sessions#create', as: :user_session
  match 'signout', to: 'devise/sessions#destroy', as: :destroy_user_session, via: Devise.mappings[:user].sign_out_via
end

 
  resources :notacredits do
    collection { post :import }
    collection { post :sendsunat }
    collection { post :print }
    collection { post :xml }
    collection { post :sendmail }
    collection { get :search   }


  end 


   resources :invoices do
    collection { post :import }
    collection { post :sendsunat }
    collection { post :print }
    collection { post :xml }
    collection { post :sendmail }
    collection { get :search   }
      collection do 
      put :editmultiple      
      put :updatemultiple      
    end 

   end 
   
   resources :clients do
    collection { post :import }
    collection { get :search   }
   end 

   resources :voideds do
    collection { post :anular }  
    collection { post :anular2 }  
   end 

   get '/about', to: 'layouts#about'

   resources :assets do
    member do
      get 'download'
    end
   end

  root 'invoices#index'


    match 'reports/monthly_customers' => 'reports#report_monthly_customers', via: [:get, :post]
    match 'reports/view_monthly_customers/:customer_id' => 'reports#report_view_monthly_customers', via: [:get, :post]
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
