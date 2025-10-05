require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin)
    @teacher_user = users(:teacher)
    @student_user = users(:student)
  end

  test "should get index for admin" do
    sign_in @admin_user
    get analytics_url
    assert_response :success
    assert_select "h1", "Analytics Dashboard"
  end

  test "should get index for teacher" do
    sign_in @teacher_user
    get analytics_url
    assert_response :success
  end

  test "should redirect student from analytics" do
    sign_in @student_user
    get analytics_url
    assert_redirected_to root_path
  end

  test "should get performance data for admin" do
    sign_in @admin_user
    get analytics_performance_data_url
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  test "should get skills data for admin" do
    sign_in @admin_user
    get analytics_skills_data_url
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  test "should get distribution data for admin" do
    sign_in @admin_user
    get analytics_distribution_data_url
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  test "should get score range data for admin" do
    sign_in @admin_user
    get analytics_score_range_data_url
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  test "should require authentication for analytics" do
    get analytics_url
    assert_redirected_to new_user_session_path
  end
end
