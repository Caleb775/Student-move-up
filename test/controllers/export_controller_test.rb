require "test_helper"

class ExportControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin)
    @teacher_user = users(:teacher)
    @student_user = users(:student)
  end

  test "should get index for admin" do
    sign_in @admin_user
    get export_url
    assert_response :success
    assert_select "h1", "Export Data"
  end

  test "should get index for teacher" do
    sign_in @teacher_user
    get export_url
    assert_response :success
  end

  test "should redirect student from export" do
    sign_in @student_user
    get export_url
    assert_redirected_to root_path
  end

  test "should export students csv for admin" do
    sign_in @admin_user
    get export_students_csv_url
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_includes response.headers["Content-Disposition"], "students.csv"
  end

  test "should export students xlsx for admin" do
    sign_in @admin_user
    get "/export/students.xlsx"
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.content_type
    assert_includes response.headers["Content-Disposition"], "students.xlsx"
  end

  test "should export notes csv for admin" do
    sign_in @admin_user
    get export_notes_csv_url
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_includes response.headers["Content-Disposition"], "notes.csv"
  end

  test "should export notes xlsx for admin" do
    sign_in @admin_user
    get "/export/notes.xlsx"
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.content_type
    assert_includes response.headers["Content-Disposition"], "notes.xlsx"
  end

  test "should export analytics report for admin" do
    sign_in @admin_user
    get "/export/analytics.xlsx"
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.content_type
    assert_includes response.headers["Content-Disposition"], "analytics_report.xlsx"
  end

  test "should require authentication for export" do
    get export_url
    assert_redirected_to new_user_session_path
  end
end
