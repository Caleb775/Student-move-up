class ImportController < ApplicationController
  before_action :authenticate_user!
  before_action :check_import_access
  skip_authorization_check

  # Ensure Axlsx is available
  require "axlsx" if defined?(Axlsx)

  def index
    @import_templates = {
      students: {
        csv: { name: "Students CSV Template", description: "Download template for importing students" },
        xlsx: { name: "Students Excel Template", description: "Download template for importing students" }
      }
    }
  end

  def download_template
    type = params[:type] # 'students'
    format = params[:format] # 'csv' or 'xlsx'

    Rails.logger.debug "DEBUG: download_template called with type=#{type}, format=#{format}"

    case type
    when "students"
      case format
      when "csv"
        Rails.logger.debug "DEBUG: Calling download_students_csv_template"
        download_students_csv_template
      when "xlsx"
        Rails.logger.debug "DEBUG: Calling download_students_xlsx_template"
        download_students_xlsx_template
      else
        Rails.logger.debug "DEBUG: Invalid format specified: #{format}"
        redirect_to import_path, alert: "Invalid format specified."
      end
    else
      Rails.logger.debug "DEBUG: Invalid type specified: #{type}"
      redirect_to import_path, alert: "Invalid import type specified."
    end
  end

  def upload
    @file = params[:file]
    @import_type = params[:import_type]

    if @file.blank?
      redirect_to import_path, alert: "Please select a file to import."
      return
    end

    begin
      case @import_type
      when "students"
        import_students
      else
        redirect_to import_path, alert: "Invalid import type specified."
      end
    rescue => e
      redirect_to import_path, alert: "Import failed: #{e.message}"
    end
  end

  private

  def check_import_access
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to access import features."
    end
  end

  def download_students_csv_template
    response.headers["Content-Type"] = "text/csv"
    response.headers["Content-Disposition"] = "attachment; filename=students_import_template.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      # Headers
      csv << [ "Name", "Reading", "Writing", "Listening", "Speaking", "Teacher Email" ]

      # Sample data
      csv << [ "John Doe", 8, 7, 9, 6, "teacher@example.com" ]
      csv << [ "Jane Smith", 9, 8, 7, 8, "teacher@example.com" ]
      csv << [ "Bob Johnson", 7, 9, 8, 7, "teacher@example.com" ]
    end

    render plain: csv_data
  end

  def download_students_xlsx_template
    respond_to do |format|
      format.xlsx {
        response.headers["Content-Type"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        response.headers["Content-Disposition"] = "attachment; filename=students_import_template.xlsx"

        package = Axlsx::Package.new
        workbook = package.workbook

        # Add styles
        styles = workbook.styles
        header_style = styles.add_style(bg_color: "366092", fg_color: "FFFFFF", b: true)
        data_style = styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
        instruction_style = styles.add_style(bg_color: "FFF2CC", b: true)

    # Template sheet
    workbook.add_worksheet(name: "Students Template") do |sheet|
      # Instructions
      sheet.add_row([ "IMPORT INSTRUCTIONS" ], style: instruction_style)
      sheet.add_row([ "1. Fill in the data below the headers" ], style: data_style)
      sheet.add_row([ "2. Name: Student full name (required)" ], style: data_style)
      sheet.add_row([ "3. Reading, Writing, Listening, Speaking: Scores 0-10 (required)" ], style: data_style)
      sheet.add_row([ "4. Teacher Email: Email of assigned teacher (optional)" ], style: data_style)
      sheet.add_row([ "5. Save as CSV or Excel and upload" ], style: data_style)
      sheet.add_row([]) # Empty row

      # Headers
      sheet.add_row([ "Name", "Reading", "Writing", "Listening", "Speaking", "Teacher Email" ], style: header_style)

      # Sample data
      sheet.add_row([ "John Doe", 8, 7, 9, 6, "teacher@example.com" ], style: data_style)
      sheet.add_row([ "Jane Smith", 9, 8, 7, 8, "teacher@example.com" ], style: data_style)
      sheet.add_row([ "Bob Johnson", 7, 9, 8, 7, "teacher@example.com" ], style: data_style)

      # Auto-size columns
      sheet.column_widths(20, 10, 10, 10, 10, 25)
    end

        send_data package.to_stream.read, filename: "students_import_template.xlsx"
      }
    end
  end

  def import_students
    file_extension = File.extname(@file.original_filename).downcase
    imported_count = 0
    errors = []

    case file_extension
    when ".csv"
      imported_count, errors = import_students_from_csv
    when ".xlsx", ".xls"
      imported_count, errors = import_students_from_excel
    else
      redirect_to import_path, alert: "Unsupported file format. Please use CSV or Excel files."
      return
    end

    if errors.any?
      redirect_to import_path, alert: "Import completed with #{imported_count} students imported. Errors: #{errors.join(', ')}"
    else
      redirect_to import_path, notice: "Successfully imported #{imported_count} students."
    end
  end

  def import_students_from_csv
    imported_count = 0
    errors = []

    CSV.foreach(@file.path, headers: true) do |row|
      begin
        student_data = {
          name: row["Name"]&.strip,
          reading: row["Reading"]&.to_i,
          writing: row["Writing"]&.to_i,
          listening: row["Listening"]&.to_i,
          speaking: row["Speaking"]&.to_i
        }

        # Validate required fields
        if student_data[:name].blank?
          errors << "Row #{$.}: Name is required"
          next
        end

        # Validate scores (0-10)
        [ :reading, :writing, :listening, :speaking ].each do |skill|
          score = student_data[skill]
          if score.nil? || score < 0 || score > 10
            errors << "Row #{$.}: #{skill.to_s.capitalize} score must be between 0-10"
            next
          end
        end

        # Find or assign teacher
        teacher_email = row["Teacher Email"]&.strip
        teacher = nil
        if teacher_email.present?
          teacher = User.find_by(email: teacher_email, role: 1) # Teacher role
          if teacher.nil?
            errors << "Row #{$.}: Teacher with email '#{teacher_email}' not found"
            next
          end
        end

        # Create student
        Student.create!(student_data.merge(user: teacher))
        imported_count += 1

      rescue => e
        errors << "Row #{$.}: #{e.message}"
      end
    end

    [ imported_count, errors ]
  end

  def import_students_from_excel
    imported_count = 0
    errors = []

    spreadsheet = Roo::Spreadsheet.open(@file.path)
    worksheet = spreadsheet.sheet(0)

    # Skip header row
    (2..worksheet.last_row).each do |row_num|
      begin
        row = worksheet.row(row_num)
        next if row.all?(&:blank?) # Skip empty rows

        student_data = {
          name: row[0]&.to_s&.strip,
          reading: row[1]&.to_i,
          writing: row[2]&.to_i,
          listening: row[3]&.to_i,
          speaking: row[4]&.to_i
        }

        # Validate required fields
        if student_data[:name].blank?
          errors << "Row #{row_num}: Name is required"
          next
        end

        # Validate scores (0-10)
        [ :reading, :writing, :listening, :speaking ].each do |skill|
          score = student_data[skill]
          if score.nil? || score < 0 || score > 10
            errors << "Row #{row_num}: #{skill.to_s.capitalize} score must be between 0-10"
            next
          end
        end

        # Find or assign teacher
        teacher_email = row[5]&.to_s&.strip
        teacher = nil
        if teacher_email.present?
          teacher = User.find_by(email: teacher_email, role: 1) # Teacher role
          if teacher.nil?
            errors << "Row #{row_num}: Teacher with email '#{teacher_email}' not found"
            next
          end
        end

        # Create student
        Student.create!(student_data.merge(user: teacher))
        imported_count += 1

      rescue => e
        errors << "Row #{row_num}: #{e.message}"
      end
    end

    [ imported_count, errors ]
  end
end
