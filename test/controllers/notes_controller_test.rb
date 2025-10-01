require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    student = students(:one)
    get student_notes_url(student)
    assert_response :success
  end

  test "should get show" do
    student = students(:one)
    note = notes(:one)
    get student_note_url(student, note)
    assert_response :success
  end

  test "should get new" do
    student = students(:one)
    get new_student_note_url(student)
    assert_response :success
  end

  test "should get edit" do
    student = students(:one)
    note = notes(:one)
    get edit_student_note_url(student, note)
    assert_response :success
  end
end
