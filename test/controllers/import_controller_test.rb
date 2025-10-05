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
    assert_includes response.headers["Content-Disposition"], "students_template.csv"
  end

  test "should download xlsx template for admin" do
    sign_in @admin_user
    get import_template_url(type: "students", format: "xlsx")
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.content_type
    assert_includes response.headers["Content-Disposition"], "students_template.xlsx"
  end

  test "should require authentication for import" do
    get import_url
    assert_redirected_to new_user_session_path
  end

  test "should handle invalid template type" do
    sign_in @admin_user
    get import_template_url(type: "invalid", format: "csv")
    assert_response :not_found
  end

  test "should handle invalid template format" do
    sign_in @admin_user
    get import_template_url(type: "students", format: "invalid")
    assert_response :not_found
  end
end
