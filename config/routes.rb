Rails.application.routes.draw do
  resources :students do
    resources :notes
  end

  root "students#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
