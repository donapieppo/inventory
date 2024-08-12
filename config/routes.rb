Rails.application.routes.draw do
  resources :nodes
  mount DmUniboCommon::Engine => "/dm_unibo_common", :as => "dm_unibo_common"

  get "/choose_organization", to: "home#choose_organization"
  get "/logins/logout", to: "dm_unibo_common/logins#logout"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up123", to: "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "projects#index"
  get "/home", to: "home#index", as: "home"

  scope ":__org__" do
    resources :users
    resources :ad_groups
    resources :projects
    resources :softwares
    resources :roles do
      member do
        get :choose_project
        patch :set_projects
      end
    end
    resources :web_sites

    get "/", to: "projects#index", as: "current_organization_root"
  end
end
