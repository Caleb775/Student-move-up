class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_analytics_access
  skip_authorization_check

  def index
    @total_students = Student.count
    @total_users = User.count
    @total_notes = Note.count
    @average_score = Student.average(:total_score)&.round(2) || 0
    @average_percentage = Student.average(:percentage)&.round(2) || 0

    # Recent activity
    @recent_students = Student.order(created_at: :desc).limit(5)
    @recent_notes = Note.joins(:student).order(created_at: :desc).limit(5)

    # Performance metrics
    @top_performers = Student.order(total_score: :desc).limit(5)
    @needs_improvement = Student.order(total_score: :asc).limit(5)

    # Skills breakdown
    @skills_average = {
      reading: Student.average(:reading)&.round(2) || 0,
      writing: Student.average(:writing)&.round(2) || 0,
      listening: Student.average(:listening)&.round(2) || 0,
      speaking: Student.average(:speaking)&.round(2) || 0
    }
  end

  def performance_data
    # Generate performance trend data
    data = {
      labels: generate_monthly_labels,
      average_scores: generate_average_scores,
      top_scores: generate_top_scores
    }

    # Add cache headers for better performance
    response.headers["Cache-Control"] = "public, max-age=300" # 5 minutes
    render json: data
  end

  def skills_data
    data = {
      average_skills: [
        Student.average(:reading)&.round(2) || 0,
        Student.average(:writing)&.round(2) || 0,
        Student.average(:listening)&.round(2) || 0,
        Student.average(:speaking)&.round(2) || 0
      ]
    }

    # Add cache headers for better performance
    response.headers["Cache-Control"] = "public, max-age=300" # 5 minutes
    render json: data
  end

  def distribution_data
    # Score distribution by percentage ranges
    excellent = Student.where("percentage >= 90").count
    good = Student.where("percentage >= 80 AND percentage < 90").count
    average = Student.where("percentage >= 70 AND percentage < 80").count
    below_average = Student.where("percentage >= 60 AND percentage < 70").count
    needs_improvement = Student.where("percentage < 60").count

    data = {
      labels: [ "Excellent (90%+)", "Good (80-89%)", "Average (70-79%)", "Below Average (60-69%)", "Needs Improvement (<60%)" ],
      values: [ excellent, good, average, below_average, needs_improvement ]
    }

    # Add cache headers for better performance
    response.headers["Cache-Control"] = "public, max-age=300" # 5 minutes
    render json: data
  end

  def score_range_data
    # Score distribution by total score ranges
    range_0_10 = Student.where("total_score >= 0 AND total_score <= 10").count
    range_11_20 = Student.where("total_score >= 11 AND total_score <= 20").count
    range_21_30 = Student.where("total_score >= 21 AND total_score <= 30").count
    range_31_35 = Student.where("total_score >= 31 AND total_score <= 35").count
    range_36_40 = Student.where("total_score >= 36 AND total_score <= 40").count

    data = {
      labels: [ "0-10", "11-20", "21-30", "31-35", "36-40" ],
      values: [ range_0_10, range_11_20, range_21_30, range_31_35, range_36_40 ]
    }

    # Add cache headers for better performance
    response.headers["Cache-Control"] = "public, max-age=300" # 5 minutes
    render json: data
  end

  private

  def check_analytics_access
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to access analytics."
    end
  end

  def generate_monthly_labels
    # Generate labels for the last 6 months
    6.times.map do |i|
      (Date.current - i.months).strftime("%b %Y")
    end.reverse
  end

  def generate_average_scores
    # Generate average scores for the last 6 months
    # For demo purposes, we'll use current data with some variation
    base_average = Student.average(:total_score) || 0
    6.times.map do |i|
      # Add some realistic variation
      variation = (rand(-3.0..3.0))
      (base_average + variation).round(2)
    end
  end

  def generate_top_scores
    # Generate top scores for the last 6 months
    max_score = Student.maximum(:total_score) || 0
    6.times.map do |i|
      # Add some realistic variation
      variation = (rand(-2.0..2.0))
      [ (max_score + variation).round(2), 40 ].min
    end
  end
end
