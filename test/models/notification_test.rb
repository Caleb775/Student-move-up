require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  def setup
    @user = users(:teacher)
    @notification = Notification.new(
      title: "Test Notification",
      message: "This is a test notification message.",
      notification_type: "info",
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @notification.valid?
  end

  test "should require title" do
    @notification.title = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:title], "can't be blank"
  end

  test "should require message" do
    @notification.message = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:message], "can't be blank"
  end

  test "should require user" do
    @notification.user = nil
    assert_not @notification.valid?
    assert_includes @notification.errors[:user], "must exist"
  end

  test "should have default read status as false" do
    @notification.save
    assert_not @notification.read
  end

  test "should belong to user" do
    @notification.save
    assert_equal @user, @notification.user
  end

  test "should have created_at timestamp" do
    @notification.save
    assert_not_nil @notification.created_at
  end

  test "should have updated_at timestamp" do
    @notification.save
    assert_not_nil @notification.updated_at
  end

  test "should allow different notification types" do
    %w[info success warning error].each do |type|
      @notification.notification_type = type
      assert @notification.valid?
    end
  end

  test "should be associated with user's notifications" do
    @notification.save
    assert_includes @user.notifications, @notification
  end

  test "should allow long messages" do
    long_message = "A" * 1000
    @notification.message = long_message
    assert @notification.valid?
  end

  test "should allow short messages" do
    @notification.message = "Short message"
    assert @notification.valid?
  end
end
