Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]
  root "dashboard#index"

  resources :investments do
    resources :snapshots, only: [ :new, :create, :destroy ]
    member do
      get  :exit_form
      patch :record_exit
    end
  end

  # Public, token-protected, read-only views
  get    "share/:token",                 to: "shares#show",        as: :share
  post   "share/:token/unlock",          to: "shares#unlock",      as: :unlock_share
  get    "share/:token/dashboard",       to: "shares#dashboard",   as: :share_dashboard
  get    "share/:token/investments/:id", to: "shares#investment",  as: :share_investment
  delete "share/:token/sign_out",        to: "shares#sign_out",    as: :share_sign_out

  # Owner-only share management
  resource :account_share, only: [ :show, :create, :destroy ], path: "account/share"

  get "up" => "rails/health#show", as: :rails_health_check
end
