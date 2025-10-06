class StudentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_user_for_student, only: [ :create ]

  # GET /students
  def index
    @search_service = StudentSearchService.new(search_params)
    @students = @search_service.search.page(params[:page]).per(10)
    @suggestions = @search_service.suggestions if params[:q].present?
  end

  # GET /students/:id
  def show
  end

  # GET /students/new
  def new
  end

  # POST /students
  def create
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
    if @student.update(student_params)
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

  # GET /students/search_suggestions
  def search_suggestions
    @search_service = StudentSearchService.new(search_params)
    @suggestions = @search_service.suggestions
    render json: @suggestions
  end

  private

  def set_user_for_student
    @student.user = current_user
  end

  def student_params
    params.require(:student).permit(:name, :reading, :writing, :listening, :speaking, :user_id)
  end

  def search_params
    params.permit(:q, :sort, filters: [
      :min_score, :max_score, :min_percentage, :max_percentage,
      :min_reading, :min_writing, :min_listening, :min_speaking,
      :created_after, :created_before, :user_id
    ])
  end
end # rubocop:disable Layout/TrailingEmptyLines