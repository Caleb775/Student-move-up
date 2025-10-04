Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :students do
    resources :notes
    collection do
      get :search_suggestions
    end
  end

  # Dashboard routes
  get "dashboard", to: "dashboard#index"
  get "admin/dashboard", to: "dashboard#admin", as: :admin_dashboard
  get "teacher/dashboard", to: "dashboard#teacher", as: :teacher_dashboard
  get "student/dashboard", to: "dashboard#student", as: :student_dashboard

  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end # rubocop:disable Layout/TrailingEmptyLines