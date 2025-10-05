require "test_helper"

class NoteTest < ActiveSupport::TestCase
  def setup
    @user = users(:teacher)
    @student = students(:one)
    @note = Note.new(
      content: "This is a test note about the student's progress.",
      student: @student,
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @note.valid?
  end

  test "should require content" do
    @note.content = nil
    assert_not @note.valid?
    assert_includes @note.errors[:content], "can't be blank"
  end

  test "should require student" do
    @note.student = nil
    assert_not @note.valid?
    assert_includes @note.errors[:student], "must exist"
  end

  test "should require user" do
    @note.user = nil
    assert_not @note.valid?
    assert_includes @note.errors[:user], "must exist"
  end

  test "should belong to student" do
    @note.save
    assert_equal @student, @note.student
  end

  test "should belong to user" do
    @note.save
    assert_equal @user, @note.user
  end

  test "should send notification after creation" do
    assert_difference "Notification.count" do
      @note.save
    end
  end

  test "should have created_at timestamp" do
    @note.save
    assert_not_nil @note.created_at
  end

  test "should have updated_at timestamp" do
    @note.save
    assert_not_nil @note.updated_at
  end

  test "should allow long content" do
    long_content = "A" * 1000
    @note.content = long_content
    assert @note.valid?
  end

  test "should allow short content" do
    @note.content = "Short note"
    assert @note.valid?
  end

  test "should be associated with student's notes" do
    @note.save
    assert_includes @student.notes, @note
  end

  test "should be associated with user's notes" do
    @note.save
    assert_includes @user.notes, @note
  end
end
