require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: 1
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require first name" do
    @user.first_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:first_name], "can't be blank"
  end

  test "should require last name" do
    @user.last_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:last_name], "can't be blank"
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    @user.save
    duplicate_user = User.new(
      first_name: "Jane",
      last_name: "Doe",
      email: "john@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: 1
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should require valid email format" do
    @user.email = "invalid-email"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  test "should require password" do
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test "should require minimum password length" do
    @user.password = "123"
    @user.password_confirmation = "123"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "should require password confirmation" do
    @user.password_confirmation = "different"
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], "doesn't match Password"
  end

  test "should have valid role" do
    @user.role = 0
    assert @user.valid?
    @user.role = 1
    assert @user.valid?
    @user.role = 2
    assert @user.valid?
    @user.role = 3
    assert_not @user.valid?
  end

  test "full_name should return first and last name" do
    @user.save
    assert_equal "John Doe", @user.full_name
  end

  test "role_name should return correct role names" do
    @user.role = 0
    assert_equal "Student", @user.role_name
    @user.role = 1
    assert_equal "Teacher", @user.role_name
    @user.role = 2
    assert_equal "Admin", @user.role_name
  end

  test "admin? should return true for admin role" do
    @user.role = 2
    assert @user.admin?
  end

  test "teacher? should return true for teacher role" do
    @user.role = 1
    assert @user.teacher?
  end

  test "student? should return true for student role" do
    @user.role = 0
    assert @user.student?
  end

  test "should generate api token on create" do
    @user.save
    assert_not_nil @user.api_token
    assert @user.api_token.length > 20
  end

  test "should regenerate api token" do
    @user.save
    old_token = @user.api_token
    @user.regenerate_api_token!
    assert_not_equal old_token, @user.api_token
  end

  test "should have many students" do
    @user.save
    student = Student.create!(
      name: "Test Student",
      reading: 8,
      writing: 7,
      listening: 9,
      speaking: 8,
      user: @user
    )
    assert_includes @user.students, student
  end

  test "should have many notes" do
    @user.save
    student = Student.create!(
      name: "Test Student",
      reading: 8,
      writing: 7,
      listening: 9,
      speaking: 8,
      user: @user
    )
    note = Note.create!(
      content: "Test note",
      student: student,
      user: @user
    )
    assert_includes @user.notes, note
  end

  test "should have many notifications" do
    @user.save
    notification = Notification.create!(
      title: "Test Notification",
      message: "Test message",
      notification_type: "info",
      user: @user
    )
    assert_includes @user.notifications, notification
  end
end
