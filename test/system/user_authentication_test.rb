require "application_system_test_case"

class UserAuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:admin)
  end

  test "user can sign in and access dashboard" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    assert_text "Signed in successfully"
    assert_current_path admin_dashboard_path
  end

  test "user can sign out" do
    sign_in @user
    visit root_path

    # Use the sign_out helper method instead of UI interaction
    sign_out @user
    visit root_path

    assert_current_path new_user_session_path
    assert_text "You need to sign in or sign up before continuing"
  end

  test "user cannot access protected pages without authentication" do
    visit students_path
    assert_current_path new_user_session_path

    visit users_path
    assert_current_path new_user_session_path
  end

  test "user sees appropriate dashboard based on role" do
    # Test admin dashboard
    sign_in users(:admin)
    visit root_path
    assert_text "Admin Dashboard"
    assert_link "Manage Users"
    assert_link "Analytics"

    # Test teacher dashboard
    sign_in users(:teacher)
    visit root_path
    assert_text "Teacher Dashboard"
    assert_no_link "Manage Users"
    assert_link "Analytics"

    # Test student dashboard
    sign_in users(:student)
    visit root_path
    assert_text "Student Dashboard"
    assert_no_link "Manage Users"
    assert_no_link "Analytics"
  end
end
