# Students Controller
#
# Handles all CRUD operations for Student records.
# Manages student creation, display, updates, and deletion with automatic score calculations.
#
# == Routes
#
# * GET    /students           => index  (list all students)
# * GET    /students/new       => new    (show form to create student)
# * POST   /students           => create (create a new student)
# * GET    /students/:id       => show   (display a student)
# * GET    /students/:id/edit  => edit   (show form to edit student)
# * PATCH  /students/:id       => update (update a student)
# * DELETE /students/:id       => destroy (delete a student)
#
# == Before Actions
#
# * set_student - Runs before show, edit, update, destroy actions
#
# == Score Calculation
#
# The controller automatically calculates total_score and percentage:
# - total_score = reading + writing + listening + speaking (max 40)
# - percentage = (total_score / 40.0) * 100
#
class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]

  # GET /students
  #
  # Lists all students ordered by percentage (highest to lowest).
  # Displays students in a table with their scores and overall performance.
  #
  # == Instance Variables
  #
  # * @students - Collection of all Student records, ordered by percentage desc
  #
  # == Template
  #
  # Renders: students/index.html.erb
  #
  def index
    @students = Student.order(percentage: :desc) # top scores first
  end

  # GET /students/:id
  #
  # Displays detailed information about a specific student,
  # including all associated notes.
  #
  # == Parameters
  #
  # * :id - Student ID (required)
  #
  # == Instance Variables
  #
  # * @student - The student record (set by before_action)
  #
  # == Template
  #
  # Renders: students/show.html.erb
  #
  def show
  end

  # GET /students/new
  #
  # Shows the form to create a new student.
  # Initializes a new Student object.
  #
  # == Instance Variables
  #
  # * @student - New Student instance
  #
  # == Template
  #
  # Renders: students/new.html.erb
  #
  def new
    @student = Student.new
  end

  # POST /students
  #
  # Creates a new student with the provided parameters.
  # Automatically calculates total_score and percentage before saving.
  #
  # == Parameters
  #
  # * student[name] - Student's name (required)
  # * student[reading] - Reading score 0-10 (required)
  # * student[writing] - Writing score 0-10 (required)
  # * student[listening] - Listening score 0-10 (required)
  # * student[speaking] - Speaking score 0-10 (required)
  #
  # == Responses
  #
  # Success:
  #   - Redirects to student show page
  #   - Flash notice: "Student successfully created"
  #
  # Failure:
  #   - Re-renders new form with validation errors
  #
  # == Example
  #
  #   POST /students
  #   params: {
  #     student: {
  #       name: "John Doe",
  #       reading: 8,
  #       writing: 7,
  #       listening: 9,
  #       speaking: 8
  #     }
  #   }
  #
  def create
    @student = Student.new(student_params)
    calculate_scores(@student)
    if @student.save
      redirect_to @student, notice: "Student successfully created"
    else
      render :new
    end
  end

  # GET /students/:id/edit
  #
  # Shows the form to edit an existing student.
  #
  # == Parameters
  #
  # * :id - Student ID (required)
  #
  # == Instance Variables
  #
  # * @student - The student to edit (set by before_action)
  #
  # == Template
  #
  # Renders: students/edit.html.erb
  #
  def edit
  end

  # PATCH/PUT /students/:id
  #
  # Updates an existing student's information.
  # Recalculates total_score and percentage before saving.
  #
  # == Parameters
  #
  # * :id - Student ID (required)
  # * student[name] - Student's name (optional)
  # * student[reading] - Reading score 0-10 (optional)
  # * student[writing] - Writing score 0-10 (optional)
  # * student[listening] - Listening score 0-10 (optional)
  # * student[speaking] - Speaking score 0-10 (optional)
  #
  # == Responses
  #
  # Success:
  #   - Redirects to student show page
  #   - Flash notice: "Student successfully updated"
  #
  # Failure:
  #   - Re-renders edit form with validation errors
  #
  # == Example
  #
  #   PATCH /students/1
  #   params: {
  #     student: {
  #       reading: 10,
  #       speaking: 9
  #     }
  #   }
  #
  def update
    @student.assign_attributes(student_params)
    calculate_scores(@student)
    if @student.save
      redirect_to @student, notice: "Student successfully updated"
    else
      render :edit
    end
  end

  # DELETE /students/:id
  #
  # Deletes a student and all associated notes (cascade delete).
  #
  # == Parameters
  #
  # * :id - Student ID (required)
  #
  # == Response
  #
  # - Redirects to students index page
  # - Flash notice: "Student successfully deleted"
  #
  # == Side Effects
  #
  # All notes associated with the student are also deleted (dependent: :destroy)
  #
  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student successfully deleted"
  end

  private

  # Sets @student instance variable by finding the student from params[:id].
  #
  # == Called By
  #
  # before_action for: show, edit, update, destroy
  #
  # == Raises
  #
  # ActiveRecord::RecordNotFound if student doesn't exist (handled by Rails)
  #
  def set_student
    @student = Student.find(params[:id])
  end

  # Strong parameters for student creation and updates.
  # Only permits whitelisted attributes to prevent mass assignment vulnerabilities.
  #
  # == Permitted Parameters
  #
  # * :name - String
  # * :reading - Integer (0-10)
  # * :writing - Integer (0-10)
  # * :listening - Integer (0-10)
  # * :speaking - Integer (0-10)
  #
  # == Returns
  #
  # ActionController::Parameters - Filtered parameters hash
  #
  def student_params
    params.require(:student).permit(:name, :reading, :writing, :listening, :speaking)
  end

  # Calculates and sets the total_score and percentage for a student.
  #
  # == Parameters
  #
  # * student - Student object (modified in place)
  #
  # == Calculations
  #
  # * total_score = reading + writing + listening + speaking (max 40)
  # * percentage = (total_score / 40.0) * 100
  #
  # == Example
  #
  #   student.reading = 8
  #   student.writing = 7
  #   student.listening = 9
  #   student.speaking = 8
  #   calculate_scores(student)
  #   # => student.total_score = 32
  #   # => student.percentage = 80.0
  #
  # == Note
  #
  # This method is called before saving in both create and update actions
  # to ensure scores are always up to date.
  #
  def calculate_scores(student)
    student.total_score = student.reading + student.writing + student.listening + student.speaking
    student.percentage = (student.total_score / 40.0) * 100  # 4 categories, max 10 each
  end
end
