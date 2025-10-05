namespace :notifications do
  desc "Send weekly reports to all teachers and admins"
  task weekly_reports: :environment do
    puts "Sending weekly reports..."
    NotificationService.send_weekly_reports
    puts "Weekly reports sent successfully!"
  end

  desc "Send welcome notifications to new users"
  task welcome_new_users: :environment do
    # Find users created in the last 24 hours who haven't received welcome notifications
    new_users = User.where(created_at: 24.hours.ago..Time.current)
                   .where.not(id: Notification.where(notification_type: "welcome").select(:user_id))

    new_users.each do |user|
      NotificationService.send_welcome_notification(user)
      puts "Welcome notification sent to #{user.email}"
    end

    puts "Welcome notifications sent to #{new_users.count} new users"
  end

  desc "Clean up old notifications (older than 30 days)"
  task cleanup_old: :environment do
    old_notifications = Notification.where("created_at < ?", 30.days.ago)
    count = old_notifications.count
    old_notifications.destroy_all
    puts "Cleaned up #{count} old notifications"
  end

  desc "Send system announcement to all users"
  task :announcement, [ :title, :message ] => :environment do |t, args|
    if args[:title].blank? || args[:message].blank?
      puts "Usage: rails notifications:announcement['Title','Message']"
      exit 1
    end

    announcement = {
      title: args[:title],
      message: args[:message]
    }

    NotificationService.send_system_announcement(announcement)
    puts "System announcement sent to all users"
  end
end
