class NotificationsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(20)
    @unread_count = NotificationService.get_unread_count(current_user)
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    NotificationService.mark_as_read(@notification)
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    NotificationService.mark_as_read(@notification)

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_as_read
    NotificationService.mark_all_as_read(current_user)

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to notifications_path, notice: "Notification deleted." }
    end
  end

  def unread_count
    count = NotificationService.get_unread_count(current_user)
    render json: { count: count }
  end
end
