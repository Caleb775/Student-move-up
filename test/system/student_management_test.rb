require "application_system_test_case"

class StudentManagementTest < ApplicationSystemTestCase
  setup do
    @teacher = users(:teacher)
    @admin = users(:admin)
    @student = users(:student)
  end

  test "teacher can create and manage students" do
    sign_in @teacher
    visit students_path

    # Create new student
    click_link "New Student"
    fill_in "Name", with: "John Doe"
    fill_in "Reading", with: "8"
    fill_in "Writing", with: "7"
    fill_in "Listening", with: "9"
    fill_in "Speaking", with: "8"
    click_button "Create Student"

    assert_text "Student was successfully created"
    assert_text "John Doe"
    assert_text "32/40"
    assert_text "80.0%"

    # Edit student
    click_link "Edit"
    fill_in "Name", with: "John Smith"
    fill_in "Reading", with: "9"
    click_button "Update Student"

    assert_text "Student was successfully updated"
    assert_text "John Smith"
    assert_text "33/40"

    # Add note
    click_link "Add Note"
    fill_in "Content", with: "Great progress in reading skills!"
    click_button "Create Note"

    assert_text "Note was successfully created"
    assert_text "Great progress in reading skills!"

    # Delete student
    click_link "Delete"
    page.driver.browser.switch_to.alert.accept

    assert_text "Student was successfully destroyed"
  end

  test "admin can manage all students" do
    sign_in @admin
    visit students_path

    assert_text "Students"
    click_link "New Student"

    fill_in "Name", with: "Admin Student"
    fill_in "Reading", with: "7"
    fill_in "Writing", with: "8"
    fill_in "Listening", with: "6"
    fill_in "Speaking", with: "9"
    click_button "Create Student"

    assert_text "Student was successfully created"
    assert_text "Admin Student"
  end

  test "student cannot access student management" do
    sign_in @student
    visit students_path

    assert_current_path root_path
    assert_text "Access denied"
  end

  test "search and filter students" do
    sign_in @teacher
    visit students_path

    # Test search functionality
    fill_in "Search students...", with: "MyString"
    click_button "Search"

    # Should show filtered results
    assert_text "MyString"
  end
end
