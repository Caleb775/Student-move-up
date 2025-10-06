require "application_system_test_case"

class AnalyticsDashboardTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
    @teacher = users(:teacher)
    @student = users(:student)
  end

  test "admin can access analytics dashboard" do
    sign_in @admin
    visit analytics_path

    assert_text "Analytics Dashboard"
    assert_text "Performance Trends"
    assert_text "Skills Breakdown"
    assert_text "Score Distribution"
    assert_text "Score Ranges"

    # Check if charts are present
    assert_selector "canvas", count: 4
  end

  test "teacher can access analytics dashboard" do
    sign_in @teacher
    visit analytics_path

    assert_text "Analytics Dashboard"
    assert_selector "canvas", count: 4
  end

  test "student cannot access analytics dashboard" do
    sign_in @student
    visit analytics_path

    # Student gets redirected to their dashboard after access denial
    assert_current_path student_dashboard_path
    assert_text "You don't have permission to access analytics"
  end

  test "analytics charts load properly" do
    sign_in @admin
    visit analytics_path

    # Wait for charts to load
    sleep 2

    # Check if chart containers are present
    assert_selector "#performanceChart"
    assert_selector "#skillsChart"
    assert_selector "#distributionChart"
    assert_selector "#scoreRangeChart"
  end

  test "analytics data is displayed correctly" do
    sign_in @admin
    visit analytics_path

    # Check for key metrics
    assert_text "Total Students"
    assert_text "Average Score"
    assert_text "Top Performers"
    assert_text "Recent Activity"
  end
end
