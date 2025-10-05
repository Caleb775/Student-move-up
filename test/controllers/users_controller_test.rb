require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin)
    @teacher_user = users(:teacher)
    @student_user = users(:student)
    @user = users(:teacher)
  end

  test "should get index for admin" do
    sign_in @admin_user
    get users_url
    assert_response :success
    assert_select "h1", "User Management"
  end

  test "should redirect non-admin from users index" do
    sign_in @teacher_user
    get users_url
    assert_redirected_to root_path
  end

  test "should get show for admin" do
    sign_in @admin_user
    get user_url(@user)
    assert_response :success
    assert_select "h1", @user.full_name
  end

  test "should get new for admin" do
    sign_in @admin_user
    get new_user_url
    assert_response :success
    assert_select "h1", "New User"
  end

  test "should create user for admin" do
    sign_in @admin_user
    assert_difference("User.count") do
      post users_url, params: {
        user: {
          first_name: "Test",
          last_name: "User",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: 1
        }
      }
    end
    assert_redirected_to user_url(User.last)
  end

  test "should get edit for admin" do
    sign_in @admin_user
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user for admin" do
    sign_in @admin_user
    patch user_url(@user), params: {
      user: {
        first_name: "Updated",
        last_name: "Name"
      }
    }
    assert_redirected_to user_url(@user)
    @user.reload
    assert_equal "Updated", @user.first_name
  end

  test "should destroy user for admin" do
    sign_in @admin_user
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end
    assert_redirected_to users_url
  end

  test "should require authentication" do
    get users_url
    assert_redirected_to new_user_session_path
  end

  test "should handle bulk actions for admin" do
    sign_in @admin_user
    post bulk_actions_users_url, params: {
      action: "delete",
      user_ids: [ @user.id ]
    }
    assert_response :success
  end
end
