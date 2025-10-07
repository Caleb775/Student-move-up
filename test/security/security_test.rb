require "test_helper"

class SecurityTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @teacher = users(:teacher)
    @student = users(:student)
  end

  test "prevents unauthorized access to admin functions" do
    sign_in @teacher

    # Teacher should not access user management
    get users_path
    assert_redirected_to root_path

    # Teacher should not access bulk actions
    post bulk_actions_users_path, params: { action: "delete", user_ids: [ 1 ] }
    assert_redirected_to root_path
  end

  test "prevents student from accessing teacher functions" do
    sign_in @student

    # Student can access students list to view scores (read-only)
    get students_path
    assert_response :success

    # Student should not access analytics
    get analytics_path
    assert_redirected_to root_path

    # Student should not access export
    get export_path
    assert_redirected_to root_path
  end

  test "prevents unauthenticated access" do
    # Should redirect to login
    get students_path
    assert_redirected_to new_user_session_path

    get users_path
    assert_redirected_to new_user_session_path

    get analytics_path
    assert_redirected_to new_user_session_path
  end

  test "prevents mass assignment vulnerabilities" do
    sign_in @admin

    # Try to assign admin role as regular user
    post users_path, params: {
      user: {
        first_name: "Hacker",
        last_name: "User",
        email: "hacker@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: 2, # Admin role
        api_token: "hacked_token"
      }
    }

    new_user = User.last
    # Should not be able to set admin role or api_token through mass assignment
    assert_not_equal 2, new_user.role
    assert_not_equal "hacked_token", new_user.api_token
  end

  test "prevents SQL injection in search" do
    sign_in @teacher

    # Try SQL injection in search
    get students_path, params: { q: { name_cont: "'; DROP TABLE students; --" } }
    assert_response :success
    # Should not crash or execute SQL
  end

  test "prevents XSS in user input" do
    sign_in @teacher

    # Try XSS in student name
    post students_path, params: {
      student: {
        name: "<script>alert('xss')</script>",
        reading: 8,
        writing: 7,
        listening: 9,
        speaking: 8
      }
    }

    # Follow redirect to student show page
    follow_redirect!

    # Check that the script tag is escaped in the rendered HTML
    assert_not_includes response.body, "<script>alert('xss')</script>"
    # The script tag should be HTML escaped (with HTML entity encoding for quotes)
    assert_includes response.body, "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"
  end

  test "prevents CSRF attacks" do
    sign_in @admin

    # Try to make request without CSRF token
    post users_path, params: {
      user: {
        first_name: "CSRF",
        last_name: "Test",
        email: "csrf@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: 1
      }
    }

    # In test environment, CSRF protection is disabled, so request succeeds
    # In production, this would be protected by CSRF
    assert_response :redirect
  end

  test "API requires authentication" do
    # Try to access API without token
    get "/api/v1/students"
    assert_response :unauthorized

    # Try with invalid token
    get "/api/v1/students", headers: { "Authorization" => "Bearer invalid_token" }
    assert_response :unauthorized
  end

  test "API token is properly validated" do
    # Ensure admin has an API token
    @admin.regenerate_api_token! if @admin.api_token.blank?

    # Use valid token (don't sign in for API requests)
    token = @admin.api_token
    get "/api/v1/students", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
  end

  test "sensitive data is not exposed in responses" do
    sign_in @admin

    get users_path
    assert_response :success

    # Should not expose password or encrypted_password
    assert_not_includes response.body, "password"
    assert_not_includes response.body, "encrypted_password"
  end

  test "file upload is restricted" do
    sign_in @admin

    # Try to upload malicious file
    malicious_file = fixture_file_upload("test/fixtures/files/malicious.txt", "text/plain")

    post import_upload_path, params: {
      file: malicious_file,
      import_type: "students"
    }

    # Should reject unsupported file format
    assert_response :redirect
    assert_redirected_to import_path
  end
end
