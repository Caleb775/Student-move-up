require "test_helper"
require "benchmark"

class LoadTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @teacher = users(:teacher)
  end

  test "students index page loads quickly" do
    sign_in @teacher

    time = Benchmark.realtime do
      get "/students"
    end

    assert_response :success
    assert time < 1.0, "Students index took #{time} seconds, should be under 1 second"
  end

  test "analytics dashboard loads quickly" do
    sign_in @admin

    time = Benchmark.realtime do
      get "/analytics"
    end

    assert_response :success
    assert time < 2.0, "Analytics dashboard took #{time} seconds, should be under 2 seconds"
  end

  test "user management page loads quickly" do
    sign_in @admin

    time = Benchmark.realtime do
      get "/users"
    end

    assert_response :success
    assert time < 1.0, "Users index took #{time} seconds, should be under 1 second"
  end

  test "student creation is performant" do
    sign_in @teacher

    time = Benchmark.realtime do
      post students_path, params: {
        student: {
          name: "Performance Test Student",
          reading: 8,
          writing: 7,
          listening: 9,
          speaking: 8
        }
      }
    end

    assert_response :redirect
    assert time < 0.5, "Student creation took #{time} seconds, should be under 0.5 seconds"
  end

  test "export functionality is performant" do
    sign_in @admin

    time = Benchmark.realtime do
      get "/export/students.csv"
    end

    assert_response :success
    assert time < 2.0, "CSV export took #{time} seconds, should be under 2 seconds"
  end

  test "database queries are optimized" do
    sign_in @teacher

    # Count database queries
    query_count = 0
    callback = lambda { |*| query_count += 1 }

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      get "/students"
    end

    assert_response :success
    assert query_count < 10, "Students index made #{query_count} queries, should be under 10"
  end
end
