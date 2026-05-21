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

  get "up" => "rails/health#show", as: :rails_health_check
end
