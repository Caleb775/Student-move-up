Rails.application.routes.draw do
  resources :students
  resources :notes

  root "students#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
