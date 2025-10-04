class DashboardController < ApplicationController
  skip_authorization_check

  def index
    if current_user.admin?
      redirect_to admin_dashboard_path
    elsif current_user.teacher?
      redirect_to teacher_dashboard_path
    elsif current_user.student?
      redirect_to student_dashboard_path
    else
      redirect_to students_path
    end
  end

  def admin
    @total_students = Student.count
    @total_users = User.count
    @recent_students = Student.order(created_at: :desc).limit(5)
    @recent_notes = Note.joins(:student).order(created_at: :desc).limit(5)
  end

  def teacher
    @my_students = Student.where(user: current_user)
    @total_students = @my_students.count
    @recent_notes = Note.joins(:student).where(students: { user: current_user }).order(created_at: :desc).limit(5)
  end

  def student
    @my_students = Student.where(user: current_user)
    @recent_notes = Note.joins(:student).where(students: { user: current_user }).order(created_at: :desc).limit(5)
  end
end # rubocop:disable Layout/TrailingEmptyLines