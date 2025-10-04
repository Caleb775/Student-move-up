class StudentSearchService
  def initialize(params = {})
    @params = params
    @query = params[:q] || ""
    @filters = params[:filters] || {}
  end

  def search
    students = Student.all

    # Apply text search
    students = apply_text_search(students) if @query.present?

    # Apply filters
    students = apply_filters(students)

    # Apply sorting
    students = apply_sorting(students)

    students
  end

  def suggestions
    return [] if @query.length < 2

    # Get suggestions from student names
    name_suggestions = Student.where("name ILIKE ?", "%#{@query}%")
                             .limit(5)
                             .pluck(:name)

    # Get suggestions from notes content
    note_suggestions = Note.joins(:student)
                          .where("notes.content ILIKE ?", "%#{@query}%")
                          .limit(5)
                          .pluck(:content)
                          .map { |content| content.truncate(50) }

    (name_suggestions + note_suggestions).uniq.first(8)
  end

  private

  def apply_text_search(students)
    # PostgreSQL full-text search
    students.where(
      "name ILIKE ? OR id IN (?)",
      "%#{@query}%",
      Note.where("content ILIKE ?", "%#{@query}%").select(:student_id)
    )
  end

  def apply_filters(students)
    # Filter by score ranges
    if @filters[:min_score].present?
      students = students.where("total_score >= ?", @filters[:min_score])
    end

    if @filters[:max_score].present?
      students = students.where("total_score <= ?", @filters[:max_score])
    end

    # Filter by percentage ranges
    if @filters[:min_percentage].present?
      students = students.where("percentage >= ?", @filters[:min_percentage])
    end

    if @filters[:max_percentage].present?
      students = students.where("percentage <= ?", @filters[:max_percentage])
    end

    # Filter by individual skill scores
    if @filters[:min_reading].present?
      students = students.where("reading >= ?", @filters[:min_reading])
    end

    if @filters[:min_writing].present?
      students = students.where("writing >= ?", @filters[:min_writing])
    end

    if @filters[:min_listening].present?
      students = students.where("listening >= ?", @filters[:min_listening])
    end

    if @filters[:min_speaking].present?
      students = students.where("speaking >= ?", @filters[:min_speaking])
    end

    # Filter by date ranges
    if @filters[:created_after].present?
      students = students.where("created_at >= ?", @filters[:created_after])
    end

    if @filters[:created_before].present?
      students = students.where("created_at <= ?", @filters[:created_before])
    end

    # Filter by user (for teachers)
    if @filters[:user_id].present?
      students = students.where(user_id: @filters[:user_id])
    end

    students
  end

  def apply_sorting(students)
    case @params[:sort]
    when "name_asc"
      students.order(:name)
    when "name_desc"
      students.order(name: :desc)
    when "score_asc"
      students.order(:total_score)
    when "score_desc"
      students.order(total_score: :desc)
    when "percentage_asc"
      students.order(:percentage)
    when "percentage_desc"
      students.order(percentage: :desc)
    when "created_asc"
      students.order(:created_at)
    when "created_desc"
      students.order(created_at: :desc)
    else
      students.order(percentage: :desc) # Default: highest scores first
    end
  end
end # rubocop:disable Layout/TrailingEmptyLines