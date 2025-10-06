class Api::V1::BaseController < ApplicationController
  # Skip CSRF protection for API
  skip_before_action :verify_authenticity_token

  # Skip regular authentication for API (we use token-based auth)
  skip_before_action :authenticate_user!

  # Use token-based authentication
  before_action :authenticate_api_user!

  # Set response format to JSON
  respond_to :json

  private

  def authenticate_api_user!
    token = request.headers["Authorization"]&.gsub("Bearer ", "")

    if token.blank?
      render json: { error: "Missing authentication token" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(api_token: token)

    if @current_user.nil?
      render json: { error: "Invalid authentication token" }, status: :unauthorized
      nil
    end
  end

  def current_user
    @current_user
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_success(data = {}, message = "Success")
    render json: {
      success: true,
      message: message,
      data: data
    }
  end
end
