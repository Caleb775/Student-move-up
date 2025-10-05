module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from CanCan::AccessDenied, with: :handle_access_denied
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from StandardError, with: :handle_standard_error
  end

  private

  def handle_record_not_found(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "The requested resource was not found."
        redirect_to root_path
      end
      format.json do
        render json: { error: "Resource not found" }, status: :not_found
      end
    end
  end

  def handle_record_invalid(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "There was an error saving the record: #{exception.record.errors.full_messages.join(', ')}"
        redirect_back(fallback_location: root_path)
      end
      format.json do
        render json: {
          error: "Validation failed",
          details: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end

  def handle_access_denied(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "You don't have permission to access this resource."
        redirect_to root_path
      end
      format.json do
        render json: { error: "Access denied" }, status: :forbidden
      end
    end
  end

  def handle_parameter_missing(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "Required parameters are missing."
        redirect_back(fallback_location: root_path)
      end
      format.json do
        render json: { error: "Missing required parameters" }, status: :bad_request
      end
    end
  end

  def handle_standard_error(exception)
    # Log the error for debugging
    Rails.logger.error "Unhandled error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "An unexpected error occurred. Please try again."
        redirect_to root_path
      end
      format.json do
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
