require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get students_url
    assert_response :success
  end

  test "should get show" do
    student = students(:one)
    get student_url(student)
    assert_response :success
  end

  test "should get new" do
    get new_student_url
    assert_response :success
  end

  test "should get edit" do
    student = students(:one)
    get edit_student_url(student)
    assert_response :success
  end
end
