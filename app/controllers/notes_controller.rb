# Notes Controller
#
# Handles all CRUD operations for Note records within the context of a Student.
# All note operations are scoped to a specific student.
#
# == Routes
#
# All routes are nested under students:
#
# * GET    /students/:student_id/notes           => index   (list all notes for student)
# * GET    /students/:student_id/notes/new       => new     (show form to create note)
# * POST   /students/:student_id/notes           => create  (create a new note)
# * GET    /students/:student_id/notes/:id       => show    (display a note)
# * GET    /students/:student_id/notes/:id/edit  => edit    (show form to edit note)
# * PATCH  /students/:student_id/notes/:id       => update  (update a note)
# * DELETE /students/:student_id/notes/:id       => destroy (delete a note)
#
# == Before Actions
#
# * set_student - Runs before all actions to establish student context
# * set_note - Runs before show, edit, update, destroy actions
#
# == Scoping
#
# All note queries are scoped through @student.notes to ensure:
# - Notes are always associated with the correct student
# - Users cannot access notes from other students
#
class NotesController < ApplicationController
  before_action :set_student
  before_action :set_note, only: [ :show, :edit, :update, :destroy ]

  # GET /students/:student_id/notes
  #
  # Lists all notes for a specific student, ordered by creation date (newest first).
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  #
  # == Instance Variables
  #
  # * @student - The parent student (set by before_action)
  # * @notes - Collection of notes for the student, ordered by created_at desc
  #
  # == Template
  #
  # Renders: notes/index.html.erb
  #
  def index
    @notes = @student.notes.order(created_at: :desc)
  end

  # GET /students/:student_id/notes/:id
  #
  # Displays a specific note.
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  # * :id - Note ID (required)
  #
  # == Instance Variables
  #
  # * @student - The parent student (set by before_action)
  # * @note - The note record (set by before_action)
  #
  # == Template
  #
  # Renders: notes/show.html.erb
  #
  def show
  end

  # GET /students/:student_id/notes/new
  #
  # Shows the form to create a new note for a student.
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  #
  # == Instance Variables
  #
  # * @student - The parent student (set by before_action)
  # * @note - New Note instance associated with the student
  #
  # == Template
  #
  # Renders: notes/new.html.erb
  #
  def new
    @note = @student.notes.build
  end

  # POST /students/:student_id/notes
  #
  # Creates a new note for a student.
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  # * note[content] - Note content (required, 1-1000 characters)
  #
  # == Responses
  #
  # Success:
  #   - Redirects to student show page
  #   - Flash notice: "Note was successfully created."
  #
  # Failure:
  #   - Re-renders new form with validation errors
  #
  # == Example
  #
  #   POST /students/1/notes
  #   params: {
  #     note: {
  #       content: "Great improvement in speaking"
  #     }
  #   }
  #
  def create
    @note = @student.notes.build(note_params)
    if @note.save
      redirect_to student_path(@student), notice: "Note was successfully created."
    else
      render :new
    end
  end

  # GET /students/:student_id/notes/:id/edit
  #
  # Shows the form to edit an existing note.
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  # * :id - Note ID (required)
  #
  # == Instance Variables
  #
  # * @student - The parent student (set by before_action)
  # * @note - The note to edit (set by before_action)
  #
  # == Template
  #
  # Renders: notes/edit.html.erb
  #
  def edit
  end

  # PATCH/PUT /students/:student_id/notes/:id
  #
  # Updates an existing note.
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  # * :id - Note ID (required)
  # * note[content] - Note content (required, 1-1000 characters)
  #
  # == Responses
  #
  # Success:
  #   - Redirects to student show page
  #   - Flash notice: "Note was successfully updated."
  #
  # Failure:
  #   - Re-renders edit form with validation errors
  #
  # == Example
  #
  #   PATCH /students/1/notes/5
  #   params: {
  #     note: {
  #       content: "Outstanding progress in all areas"
  #     }
  #   }
  #
  def update
    if @note.update(note_params)
      redirect_to student_path(@student), notice: "Note was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /students/:student_id/notes/:id
  #
  # Deletes a note.
  #
  # == Parameters
  #
  # * :student_id - Student ID (required, in URL)
  # * :id - Note ID (required)
  #
  # == Response
  #
  # - Redirects to student show page
  # - Flash notice: "Note was successfully deleted."
  #
  # == Example
  #
  #   DELETE /students/1/notes/5
  #
  def destroy
    @note.destroy
    redirect_to student_path(@student), notice: "Note was successfully deleted."
  end

  private

  # Sets @student instance variable by finding the student from params[:student_id].
  # Ensures all note operations are scoped to the correct student.
  #
  # == Called By
  #
  # before_action for all actions
  #
  # == Raises
  #
  # ActiveRecord::RecordNotFound if student doesn't exist (handled by Rails)
  #
  def set_student
    @student = Student.find(params[:student_id])
  end

  # Sets @note instance variable by finding the note within the student's notes.
  # This scoping ensures users cannot access notes from other students.
  #
  # == Called By
  #
  # before_action for: show, edit, update, destroy
  #
  # == Raises
  #
  # ActiveRecord::RecordNotFound if note doesn't exist or doesn't belong to student
  #
  def set_note
    @note = @student.notes.find(params[:id])
  end

  # Strong parameters for note creation and updates.
  # Only permits whitelisted attributes to prevent mass assignment vulnerabilities.
  #
  # == Permitted Parameters
  #
  # * :content - Text (1-1000 characters)
  #
  # == Returns
  #
  # ActionController::Parameters - Filtered parameters hash
  #
  def note_params
    params.require(:note).permit(:content)
  end
end
