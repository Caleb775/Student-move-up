require "test_helper"

class UserManagementFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin)
    @teacher_user = users(:teacher)
    @student_user = users(:student)
  end

  test "admin can manage users complete flow" do
    sign_in @admin_user

    # Visit users index
    get users_path
    assert_response :success
    assert_select "h1", "User Management"

    # Create new user
    get new_user_path
    assert_response :success

    assert_difference "User.count" do
      post users_path, params: {
        user: {
          first_name: "New",
          last_name: "Teacher",
          email: "newteacher@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: 1
        }
      }
    end

    new_user = User.last
    assert_redirected_to user_path(new_user)

    # View the new user
    get user_path(new_user)
    assert_response :success
    assert_select "h1", "New Teacher"

    # Edit the user
    get edit_user_path(new_user)
    assert_response :success

    patch user_path(new_user), params: {
      user: {
        first_name: "Updated",
        last_name: "Teacher"
      }
    }
    assert_redirected_to user_path(new_user)

    new_user.reload
    assert_equal "Updated", new_user.first_name

    # Delete the user
    assert_difference "User.count", -1 do
      delete user_path(new_user)
    end
    assert_redirected_to users_path
  end

  test "teacher cannot access user management" do
    sign_in @teacher_user

    get users_path
    assert_redirected_to root_path

    get new_user_path
    assert_redirected_to root_path
  end

  test "student cannot access user management" do
    sign_in @student_user

    get users_path
    assert_redirected_to root_path

    get new_user_path
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot access user management" do
    get users_path
    assert_redirected_to new_user_session_path

    get new_user_path
    assert_redirected_to new_user_session_path
  end

  test "admin can perform bulk actions" do
    sign_in @admin_user

    # Create test users
    user1 = User.create!(
      first_name: "Test1",
      last_name: "User",
      email: "test1@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: 1
    )

    user2 = User.create!(
      first_name: "Test2",
      last_name: "User",
      email: "test2@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: 1
    )

    # Test bulk delete
    assert_difference "User.count", -2 do
      post bulk_actions_users_path, params: {
        action: "delete",
        user_ids: [ user1.id, user2.id ]
      }
    end
    assert_response :success
  end
end
