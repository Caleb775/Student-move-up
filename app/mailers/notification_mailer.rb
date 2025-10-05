class NotificationMailer < ApplicationMailer
  default from: "noreply@studentrecords.com"

  def student_created_notification(student, teacher)
    @student = student
    @teacher = teacher
    @user = teacher

    mail(
      to: @teacher.email,
      subject: "New Student Added: #{@student.name}"
    )
  end

  def student_updated_notification(student, teacher)
    @student = student
    @teacher = teacher
    @user = teacher

    mail(
      to: @teacher.email,
      subject: "Student Updated: #{@student.name}"
    )
  end

  def note_added_notification(note, student, teacher)
    @note = note
    @student = student
    @teacher = teacher
    @user = teacher

    mail(
      to: @teacher.email,
      subject: "New Note Added for #{@student.name}"
    )
  end

  def weekly_report_notification(user, report_data)
    @user = user
    @report_data = report_data

    mail(
      to: @user.email,
      subject: "Weekly Student Progress Report - #{Date.current.strftime('%B %d, %Y')}"
    )
  end

  def system_announcement_notification(user, announcement)
    @user = user
    @announcement = announcement

    mail(
      to: @user.email,
      subject: "System Announcement: #{@announcement[:title]}"
    )
  end

  def password_reset_notification(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Password Reset Request"
    )
  end

  def welcome_notification(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Welcome to Student Records Management System"
    )
  end
end
