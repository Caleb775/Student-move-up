class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :check_export_access
  skip_authorization_check

  def index
    @export_options = {
      students: {
        csv: { name: "Students (CSV)", description: "Export all student data as CSV" },
        xlsx: { name: "Students (Excel)", description: "Export all student data as Excel" }
      },
      notes: {
        csv: { name: "Notes (CSV)", description: "Export all notes as CSV" },
        xlsx: { name: "Notes (Excel)", description: "Export all notes as Excel" }
      },
      analytics: {
        xlsx: { name: "Analytics Report", description: "Export analytics data with charts" }
      }
    }
  end

  def students_csv
    @students = Student.includes(:user, :notes)

    response.headers["Content-Type"] = "text/csv"
    response.headers["Content-Disposition"] = "attachment; filename=students.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      # Headers
      csv << [ "ID", "Name", "Reading", "Writing", "Listening", "Speaking", "Total Score", "Percentage", "Created At", "Updated At", "Teacher", "Notes Count" ]

      # Data rows
      @students.each do |student|
        csv << [
          student.id,
          student.name,
          student.reading,
          student.writing,
          student.listening,
          student.speaking,
          student.total_score,
          student.percentage.round(2),
          student.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          student.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
          student.user&.full_name || "N/A",
          student.notes.count
        ]
      end
    end

    render plain: csv_data
  end

  def students_xlsx
    @students = Student.includes(:user, :notes)

    respond_to do |format|
      format.xlsx do
        response.headers["Content-Type"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        response.headers["Content-Disposition"] = "attachment; filename=students.xlsx"

        package = Axlsx::Package.new
        workbook = package.workbook

        # Add styles
        styles = workbook.styles
        header_style = styles.add_style(bg_color: "366092", fg_color: "FFFFFF", b: true)
        data_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
        metric_style = styles.add_style(bg_color: "E6F3FF", b: true)

    # Students sheet
    workbook.add_worksheet(name: "Students") do |sheet|
      # Headers
      sheet.add_row([ "ID", "Name", "Reading", "Writing", "Listening", "Speaking", "Total Score", "Percentage", "Created At", "Updated At", "Teacher", "Notes Count" ], style: header_style)

      # Data rows
      @students.each do |student|
        sheet.add_row([
          student.id,
          student.name,
          student.reading,
          student.writing,
          student.listening,
          student.speaking,
          student.total_score,
          student.percentage.round(2),
          student.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          student.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
          student.user&.full_name || "N/A",
          student.notes.count
        ], style: data_style)
      end

      # Auto-size columns
      sheet.column_widths(8, 20, 10, 10, 10, 10, 12, 12, 18, 18, 20, 12)
    end

    # Summary sheet
    workbook.add_worksheet(name: "Summary") do |sheet|
      sheet.add_row([ "Metric", "Value" ], style: header_style)
      sheet.add_row([ "Total Students", @students.count ], style: data_style)
      sheet.add_row([ "Average Score", @students.average(:total_score)&.round(2) || 0 ], style: data_style)
      sheet.add_row([ "Average Percentage", @students.average(:percentage)&.round(2) || 0 ], style: data_style)
      sheet.add_row([ "Total Notes", Note.count ], style: data_style)
      sheet.add_row([ "Export Date", Date.current.strftime("%Y-%m-%d") ], style: data_style)

      sheet.column_widths(20, 15)
    end

        send_data package.to_stream.read, filename: "students.xlsx"
      end
    end
  end

  def notes_csv
    @notes = Note.includes(:student, :user)

    response.headers["Content-Type"] = "text/csv"
    response.headers["Content-Disposition"] = "attachment; filename=notes.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      # Headers
      csv << [ "ID", "Student Name", "Content", "Created By", "Created At", "Updated At" ]

      # Data rows
      @notes.each do |note|
        csv << [
          note.id,
          note.student.name,
          note.content,
          note.user&.full_name || "N/A",
          note.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          note.updated_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end

    render plain: csv_data
  end

  def notes_xlsx
    @notes = Note.includes(:student, :user)

    respond_to do |format|
      format.xlsx do
        response.headers["Content-Type"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        response.headers["Content-Disposition"] = "attachment; filename=notes.xlsx"

        package = Axlsx::Package.new
        workbook = package.workbook

        # Add styles
        styles = workbook.styles
        header_style = styles.add_style(bg_color: "366092", fg_color: "FFFFFF", b: true)
        data_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER)

    # Notes sheet
    workbook.add_worksheet(name: "Notes") do |sheet|
      # Headers
      sheet.add_row([ "ID", "Student Name", "Content", "Created By", "Created At", "Updated At" ], style: header_style)

      # Data rows
      @notes.each do |note|
        sheet.add_row([
          note.id,
          note.student.name,
          note.content,
          note.user&.full_name || "N/A",
          note.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          note.updated_at.strftime("%Y-%m-%d %H:%M:%S")
        ], style: data_style)
      end

      # Auto-size columns
      sheet.column_widths(8, 20, 50, 20, 18, 18)
    end

        send_data package.to_stream.read, filename: "notes.xlsx"
      end
    end
  end

  def analytics_report
    @students = Student.all
    @notes = Note.all
    @users = User.all

    respond_to do |format|
      format.xlsx do
        response.headers["Content-Type"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        response.headers["Content-Disposition"] = "attachment; filename=analytics_report.xlsx"

        package = Axlsx::Package.new
        workbook = package.workbook

        # Add styles
        styles = workbook.styles
        header_style = styles.add_style(bg_color: "366092", fg_color: "FFFFFF", b: true)
        data_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
        metric_style = styles.add_style(bg_color: "E6F3FF", b: true)

    # Analytics Summary Sheet
    workbook.add_worksheet(name: "Analytics Summary") do |sheet|
      sheet.add_row([ "Student Records Analytics Report" ], style: styles.add_style(fg_color: "366092", b: true, sz: 16))
      sheet.add_row([ "Generated on: " + Date.current.strftime("%B %d, %Y") ], style: data_style)
      sheet.add_row([]) # Empty row

      # Key Metrics
      sheet.add_row([ "Key Metrics" ], style: header_style)
      sheet.add_row([ "Total Students", @students.count ], style: metric_style)
      sheet.add_row([ "Total Users", @users.count ], style: metric_style)
      sheet.add_row([ "Total Notes", @notes.count ], style: metric_style)
      sheet.add_row([ "Average Score", @students.average(:total_score)&.round(2) || 0 ], style: metric_style)
      sheet.add_row([ "Average Percentage", @students.average(:percentage)&.round(2) || 0 ], style: metric_style)
      sheet.add_row([]) # Empty row

      # Skills Breakdown
      sheet.add_row([ "Skills Breakdown" ], style: header_style)
      sheet.add_row([ "Reading Average", @students.average(:reading)&.round(2) || 0 ], style: data_style)
      sheet.add_row([ "Writing Average", @students.average(:writing)&.round(2) || 0 ], style: data_style)
      sheet.add_row([ "Listening Average", @students.average(:listening)&.round(2) || 0 ], style: data_style)
      sheet.add_row([ "Speaking Average", @students.average(:speaking)&.round(2) || 0 ], style: data_style)

      sheet.column_widths(25, 15)
    end

    # Student Performance Sheet
    workbook.add_worksheet(name: "Student Performance") do |sheet|
      sheet.add_row([ "ID", "Name", "Reading", "Writing", "Listening", "Speaking", "Total Score", "Percentage", "Rank" ], style: header_style)

      # Sort students by total score for ranking
      ranked_students = @students.order(total_score: :desc)
      ranked_students.each_with_index do |student, index|
        sheet.add_row([
          student.id,
          student.name,
          student.reading,
          student.writing,
          student.listening,
          student.speaking,
          student.total_score,
          student.percentage.round(2),
          index + 1
        ], style: data_style)
      end

      sheet.column_widths(8, 20, 10, 10, 10, 10, 12, 12, 8)
    end

    # Notes Analysis Sheet
    workbook.add_worksheet(name: "Notes Analysis") do |sheet|
      sheet.add_row([ "Student Name", "Notes Count", "Latest Note Date", "Most Active Teacher" ], style: header_style)

      # Group notes by student
      student_notes = @notes.group_by(&:student)
      student_notes.each do |student, notes|
        latest_note = notes.max_by(&:created_at)
        most_active_teacher = notes.group_by(&:user).max_by { |_, user_notes| user_notes.count }&.first

        sheet.add_row([
          student.name,
          notes.count,
          latest_note.created_at.strftime("%Y-%m-%d"),
          most_active_teacher&.full_name || "N/A"
        ], style: data_style)
      end

      sheet.column_widths(20, 12, 15, 20)
    end

        send_data package.to_stream.read, filename: "analytics_report.xlsx"
      end
    end
  end

  private

  def check_export_access
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to access export features."
    end
  end
end
