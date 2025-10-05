class NotificationService
  def self.send_student_created_notification(student, teacher)
    return unless teacher&.email.present?

    # Create in-app notification
    Notification.create!(
      user: teacher,
      title: "New Student Added",
      message: "#{student.name} has been added to your class with a score of #{student.total_score}/40.",
      notification_type: "student_created",
      read: false
    )

    # Send email notification
    NotificationMailer.student_created_notification(student, teacher).deliver_later
  end

  def self.send_student_updated_notification(student, teacher)
    return unless teacher&.email.present?

    # Create in-app notification
    Notification.create!(
      user: teacher,
      title: "Student Updated",
      message: "#{student.name}'s information has been updated. New score: #{student.total_score}/40.",
      notification_type: "student_updated",
      read: false
    )

    # Send email notification
    NotificationMailer.student_updated_notification(student, teacher).deliver_later
  end

  def self.send_note_added_notification(note, student, teacher)
    return unless teacher&.email.present?

    # Create in-app notification
    Notification.create!(
      user: teacher,
      title: "New Note Added",
      message: "A new note has been added for #{student.name}: #{truncate(note.content, length: 50)}",
      notification_type: "note_added",
      read: false
    )

    # Send email notification
    NotificationMailer.note_added_notification(note, student, teacher).deliver_later
  end

  def self.send_welcome_notification(user)
    return unless user&.email.present?

    # Create in-app notification
    Notification.create!(
      user: user,
      title: "Welcome!",
      message: "Welcome to the Student Records Management System! Your account has been created successfully.",
      notification_type: "welcome",
      read: false
    )

    # Send email notification
    NotificationMailer.welcome_notification(user).deliver_later
  end

  def self.send_weekly_reports
    # Get all teachers and admins
    users = User.where(role: [ 1, 2 ]) # Teachers and Admins

    users.each do |user|
      next unless user.email.present?

      # Generate report data for this user
      report_data = generate_weekly_report_data(user)

      # Create in-app notification
      Notification.create!(
        user: user,
        title: "Weekly Report Available",
        message: "Your weekly student progress report is ready. #{report_data[:total_students]} students, #{report_data[:new_notes]} new notes.",
        notification_type: "weekly_report",
        read: false
      )

      # Send email notification
      NotificationMailer.weekly_report_notification(user, report_data).deliver_later
    end
  end

  def self.send_system_announcement(announcement, target_users = nil)
    users = target_users || User.all

    users.each do |user|
      next unless user.email.present?

      # Create in-app notification
      Notification.create!(
        user: user,
        title: announcement[:title],
        message: announcement[:message],
        notification_type: "system_announcement",
        read: false
      )

      # Send email notification
      NotificationMailer.system_announcement_notification(user, announcement).deliver_later
    end
  end

  def self.mark_as_read(notification)
    notification.update(read: true)
  end

  def self.mark_all_as_read(user)
    user.notifications.where(read: false).update_all(read: true)
  end

  def self.get_unread_count(user)
    user.notifications.where(read: false).count
  end

  def self.get_recent_notifications(user, limit = 10)
    user.notifications.order(created_at: :desc).limit(limit)
  end

  private

  def self.generate_weekly_report_data(user)
    # Get date range for this week
    start_date = 1.week.ago.beginning_of_week
    end_date = 1.week.ago.end_of_week

    # Get user's students
    students = user.students

    # Calculate metrics
    total_students = students.count
    new_notes = user.notes.where(created_at: start_date..end_date).count
    average_score = students.average(:total_score)&.round(2) || 0

    # Get top performers (students with score >= 35)
    top_performers = students.where("total_score >= ?", 35).count

    # Get recent students (added this week)
    recent_students = students.where(created_at: start_date..end_date).limit(5)

    # Get recent notes
    recent_notes = user.notes.includes(:student).where(created_at: start_date..end_date).limit(5)

    # Get students showing improvement (placeholder - would need historical data)
    improvements = students.order(total_score: :desc).limit(3)

    {
      total_students: total_students,
      new_notes: new_notes,
      average_score: average_score,
      top_performers: top_performers,
      recent_students: recent_students,
      recent_notes: recent_notes,
      improvements: improvements
    }
  end

  def self.truncate(text, length: 50)
    return text if text.length <= length
    text[0...length] + "..."
  end
end
