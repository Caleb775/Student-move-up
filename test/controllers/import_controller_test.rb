require "test_helper"

class ImportControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin)
    @teacher_user = users(:teacher)
    @student_user = users(:student)
  end

  test "should get index for admin" do
    sign_in @admin_user
    get import_url
    assert_response :success
    assert_select "h1", "Import Data"
  end

  test "should get index for teacher" do
    sign_in @teacher_user
    get import_url
    assert_response :success
  end

  test "should redirect student from import" do
    sign_in @student_user
    get import_url
    assert_redirected_to root_path
  end

  test "should download csv template for admin" do
    sign_in @admin_user
    get import_template_url(type: "students", format: "csv")
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_includes response.headers["Content-Disposition"], "students_import_template.csv"
  end

  test "should download xlsx template for admin" do
    sign_in @admin_user
    # Debug: Check if admin user is actually an admin
    assert @admin_user.admin?, "Admin user should be an admin (role: #{@admin_user.role})"

    # Debug: Check MIME type registration
    puts "DEBUG: XLSX MIME type: #{Mime[:xlsx]}"

    puts "DEBUG: Making request to /import/template/students with xlsx format"
    get "/import/template/students", params: { format: :xlsx }

    puts "DEBUG: Request format: #{request.format}"

    puts "DEBUG: Response status: #{response.status}"
    puts "DEBUG: Response headers: #{response.headers.to_h}"
    puts "DEBUG: Response body (first 200 chars): #{response.body[0..200]}"

    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.content_type
    assert_includes response.headers["Content-Disposition"], "students_import_template.xlsx"
  end

  test "should require authentication for import" do
    get import_url
    assert_redirected_to new_user_session_path
  end

  test "should handle invalid template type" do
    sign_in @admin_user
    get import_template_url(type: "invalid", format: "csv")
    assert_response :redirect
    assert_redirected_to import_path
  end

  test "should handle invalid template format" do
    sign_in @admin_user
    get import_template_url(type: "students", format: "invalid")
    assert_response :redirect
    assert_redirected_to import_path
  end
end
