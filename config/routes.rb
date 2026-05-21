Rails.application.routes.draw do
  root "dashboard#index"

  resources :investments do
    resources :snapshots, only: [ :new, :create ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
