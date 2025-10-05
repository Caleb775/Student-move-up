class ApplicationController < ActionController::Base
  include ErrorHandling

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authentication and Authorization
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # CanCanCan authorization
  check_authorization unless: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :role ])
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def auth_page?
    devise_controller? && (action_name == "new" || action_name == "create")
  end
  helper_method :auth_page?
end # rubocop:disable Layout/TrailingEmptyLines