Bluemob::Application.routes.draw do

  devise_for :users
  namespace :manage do

    resources :account_bills do
      resources :account_bill_infos
      member do
        get 'create_new', 'change_state'
        get "add_image", "payed_invoice", 'update_all'
        post "pay_confirm", 'admin_update'
      end
    end

    resources :platforms do
      member do
        get 'adv_contents', 'platform_balanceios'
      end
      resources :platform_accounts do
        resources :platform_balanceios
      end

      match 'platform_balanceio/balanceio', to: 'platform_balanceios#balanceio', via: 'post'
    end

    resources :applications do
      member do
        get 'charts', 'adv_settings', 'adv_contents', 'copy_channel', 'del_adv_content'
      end
      collection do
        get 'list', 'activity_app'
        post 'multi'
      end
    end

    match 'adv_tactics/multi', to: 'adv_tactics#multi', via: 'post'

    resources :adv_settings do
      collection do
        get :default_channel
        post 'multi'
      end

      member do
        post :active_setting
      end
      resources :adv_tactics do
        member do
          get 'make_relationship', 'del_relationship', 'sort_adv_content'
          post 'sort_result'
        end
      end
    end

    resources :adv_content_account_notifies, only:[:index, :show, :destroy]
    resources :adv_contents do
      collection do
        get 'all_adv_advertiser_reports' => 'adv_advertiser_reports#all'
        get 'get_data', 'trash', 'deleted', 'generate_notify'
        post 'search_autocomplete'
      end
      member do
        get 'applications', 'charts', 'advtatics', 'plant', 'put_trash', 'state_operate'
        post 'active_content'
      end
      resources :adv_details
      resources :adv_advertiser_reports
    end
    resources :profiles
    resources :payments do
      patch :update_state, on: :collection
    end
    resources :users do
      collection do
        get 'search'
      end
    end

    resources :channels do
      member do
        get :create_apk
      end
      resources :rules
    end

    # custom page
    get "welcome" => 'pages#welcome'
    get "dashboard" => 'pages#dashboard'
    get "pages/download"
    get "charts/daily_view"
    get "charts/income_view"
    get "charts/channel_view"
    get "charts/channel_data"
    get "charts/channel_data_detail"
    get "faq" => 'pages#faq'

    root "pages#welcome"
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#welcome'

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
