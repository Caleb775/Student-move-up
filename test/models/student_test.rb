require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def setup
    @user = users(:teacher)
    @student = Student.new(
      name: "John Doe",
      reading: 8,
      writing: 7,
      listening: 9,
      speaking: 8,
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @student.valid?
  end

  test "should require name" do
    @student.name = nil
    assert_not @student.valid?
    assert_includes @student.errors[:name], "can't be blank"
  end

  test "should require user" do
    @student.user = nil
    assert_not @student.valid?
    assert_includes @student.errors[:user], "must exist"
  end

  test "should require reading score" do
    @student.reading = nil
    assert_not @student.valid?
    assert_includes @student.errors[:reading], "can't be blank"
  end

  test "should require writing score" do
    @student.writing = nil
    assert_not @student.valid?
    assert_includes @student.errors[:writing], "can't be blank"
  end

  test "should require listening score" do
    @student.listening = nil
    assert_not @student.valid?
    assert_includes @student.errors[:listening], "can't be blank"
  end

  test "should require speaking score" do
    @student.speaking = nil
    assert_not @student.valid?
    assert_includes @student.errors[:speaking], "can't be blank"
  end

  test "should validate reading score range" do
    @student.reading = -1
    assert_not @student.valid?
    assert_includes @student.errors[:reading], "must be greater than or equal to 0"

    @student.reading = 11
    assert_not @student.valid?
    assert_includes @student.errors[:reading], "must be less than or equal to 10"

    @student.reading = 5
    assert @student.valid?
  end

  test "should validate writing score range" do
    @student.writing = -1
    assert_not @student.valid?
    assert_includes @student.errors[:writing], "must be greater than or equal to 0"

    @student.writing = 11
    assert_not @student.valid?
    assert_includes @student.errors[:writing], "must be less than or equal to 10"

    @student.writing = 5
    assert @student.valid?
  end

  test "should validate listening score range" do
    @student.listening = -1
    assert_not @student.valid?
    assert_includes @student.errors[:listening], "must be greater than or equal to 0"

    @student.listening = 11
    assert_not @student.valid?
    assert_includes @student.errors[:listening], "must be less than or equal to 10"

    @student.listening = 5
    assert @student.valid?
  end

  test "should validate speaking score range" do
    @student.speaking = -1
    assert_not @student.valid?
    assert_includes @student.errors[:speaking], "must be greater than or equal to 0"

    @student.speaking = 11
    assert_not @student.valid?
    assert_includes @student.errors[:speaking], "must be less than or equal to 10"

    @student.speaking = 5
    assert @student.valid?
  end

  test "should calculate total score correctly" do
    @student.save
    expected_total = 8 + 7 + 9 + 8
    assert_equal expected_total, @student.total_score
  end

  test "should calculate percentage correctly" do
    @student.save
    expected_percentage = ((8 + 7 + 9 + 8) / 40.0) * 100
    assert_equal expected_percentage, @student.percentage
  end

  test "should belong to user" do
    @student.save
    assert_equal @user, @student.user
  end

  test "should have many notes" do
    @student.save
    note = Note.create!(
      content: "Test note",
      student: @student,
      user: @user
    )
    assert_includes @student.notes, note
  end

  test "should send notification after creation" do
    assert_difference "Notification.count" do
      @student.save
    end
  end

  test "should send notification after update" do
    @student.save
    assert_difference "Notification.count" do
      @student.update!(name: "Updated Name")
    end
  end
end
