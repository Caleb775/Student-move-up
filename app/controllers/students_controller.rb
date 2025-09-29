class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]

  # GET /students
  def index
    @students = Student.order(percentage: :desc) # top scores first
  end

  # GET /students/:id
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # POST /students
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
  def edit
  end

  # PATCH/PUT /students/:id
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
  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student successfully deleted"
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :reading, :writing, :listening, :speaking)
  end

  def calculate_scores(student)
    student.total_score = student.reading + student.writing + student.listening + student.speaking
    student.percentage = (student.total_score / 40.0) * 100  # 4 categories, max 10 each
  end
end
