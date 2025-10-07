require "test_helper"

class StudentManagementFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin)
    @teacher_user = users(:teacher)
    @student_user = users(:student)
  end

  test "teacher can manage students complete flow" do
    sign_in @teacher_user

    # Visit students index
    get students_path
    assert_response :success
    assert_select "h1", "Student Rankings"

    # Create new student
    get new_student_path
    assert_response :success

    assert_difference "Student.count" do
      post students_path, params: {
        student: {
          name: "New Student",
          reading: 8,
          writing: 7,
          listening: 9,
          speaking: 8
        }
      }
    end

    new_student = Student.last
    assert_redirected_to student_path(new_student)

    # View the new student
    get student_path(new_student)
    assert_response :success
    assert_select "h2", "Student Details: New Student"

    # Edit the student
    get edit_student_path(new_student)
    assert_response :success

    patch student_path(new_student), params: {
      student: {
        name: "Updated Student",
        reading: 9
      }
    }
    assert_redirected_to student_path(new_student)

    new_student.reload
    assert_equal "Updated Student", new_student.name
    assert_equal 9, new_student.reading

    # Add a note
    get new_student_note_path(new_student)
    assert_response :success

    assert_difference "Note.count" do
      post student_notes_path(new_student), params: {
        note: {
          content: "This student is making great progress!"
        }
      }
    end

    new_note = Note.last
    assert_redirected_to student_path(new_student)

    # View the note on student show page
    get student_path(new_student)
    assert_response :success
    assert_select "p", "This student is making great progress!"

    # Edit the note
    get edit_student_note_path(new_student, new_note)
    assert_response :success

    patch student_note_path(new_student, new_note), params: {
      note: {
        content: "Updated note content"
      }
    }
    assert_redirected_to student_path(new_student)

    new_note.reload
    assert_equal "Updated note content", new_note.content

    # Delete the note
    assert_difference "Note.count", -1 do
      delete student_note_path(new_student, new_note)
    end
    assert_redirected_to student_path(new_student)

    # Delete the student
    assert_difference "Student.count", -1 do
      delete student_path(new_student)
    end
    assert_redirected_to students_path
  end

  test "admin can manage students" do
    sign_in @admin_user

    get students_path
    assert_response :success

    get new_student_path
    assert_response :success

    assert_difference "Student.count" do
      post students_path, params: {
        student: {
          name: "Admin Student",
          reading: 7,
          writing: 8,
          listening: 6,
          speaking: 9
        }
      }
    end
  end

  test "student cannot manage students" do
    sign_in @student_user

    # Student can view students list (read-only)
    get students_path
    assert_response :success

    # Student cannot create new students
    get new_student_path
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot access students" do
    get students_path
    assert_redirected_to new_user_session_path

    get new_student_path
    assert_redirected_to new_user_session_path
  end
end
