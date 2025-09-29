require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module StudentRecordsApp
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8
    config.load_defaults 8.0

    # Configuration for the application, engines, and railties goes here.
    #
    # Example:
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
