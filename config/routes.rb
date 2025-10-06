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

  # Analytics routes
  get "analytics", to: "analytics#index", as: :analytics
  get "analytics/performance_data", to: "analytics#performance_data"
  get "analytics/skills_data", to: "analytics#skills_data"
  get "analytics/distribution_data", to: "analytics#distribution_data"
  get "analytics/score_range_data", to: "analytics#score_range_data"

  # Export routes
  get "export", to: "export#index", as: :export
  get "export/students.csv", to: "export#students_csv", as: :export_students_csv
  get "export/students.xlsx", to: "export#students_xlsx", as: :export_students_xlsx, defaults: { format: :xlsx }
  get "export/notes.csv", to: "export#notes_csv", as: :export_notes_csv, defaults: { format: :csv }
  get "export/notes.xlsx", to: "export#notes_xlsx", as: :export_notes_xlsx, defaults: { format: :xlsx }
  get "export/analytics.xlsx", to: "export#analytics_report", as: :export_analytics_xlsx, defaults: { format: :xlsx }

  # Import routes
  get "import", to: "import#index", as: :import
  get "import/template/:type/:format", to: "import#download_template", as: :import_template, defaults: { format: :xlsx }
  post "import/upload", to: "import#upload", as: :import_upload

  # User management routes
  resources :users do
    collection do
      post :bulk_actions
    end
  end

  # Notification routes
  resources :notifications, only: [ :index, :show, :destroy ] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
      get :unread_count
    end
  end

  # API routes
  get "api", to: "api#index", as: :api_documentation
  namespace :api do
    namespace :v1 do
      resources :students do
        collection do
          get :stats
        end
        resources :notes
      end
    end
  end

  # PWA routes
  get "manifest", to: "pwa#manifest", as: :pwa_manifest
  get "service-worker", to: "pwa#service_worker", as: :pwa_service_worker

  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end # rubocop:disable Layout/TrailingEmptyLines