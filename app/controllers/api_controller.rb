class ApiController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_access
  skip_authorization_check

  def index
    @current_user_token = current_user.api_token
    @api_endpoints = {
      students: {
        index: {
          method: "GET",
          url: "/api/v1/students",
          description: "Get list of students",
          parameters: {
            search: "Search by name (optional)",
            min_score: "Minimum total score (optional)",
            max_score: "Maximum total score (optional)",
            page: "Page number (optional, default: 1)",
            per_page: "Items per page (optional, default: 10, max: 100)"
          },
          example_response: {
            students: [
              {
                id: 1,
                name: "John Doe",
                reading: 8,
                writing: 7,
                listening: 9,
                speaking: 6,
                total_score: 30,
                percentage: 75.0,
                notes_count: 3,
                created_at: "2024-01-01T00:00:00Z",
                updated_at: "2024-01-01T00:00:00Z"
              }
            ],
            pagination: {
              current_page: 1,
              total_pages: 1,
              total_count: 1,
              per_page: 10
            }
          }
        },
        show: {
          method: "GET",
          url: "/api/v1/students/:id",
          description: "Get student details with notes",
          example_response: {
            student: {
              id: 1,
              name: "John Doe",
              reading: 8,
              writing: 7,
              listening: 9,
              speaking: 6,
              total_score: 30,
              percentage: 75.0,
              notes: [
                {
                  id: 1,
                  content: "Great progress in reading",
                  created_at: "2024-01-01T00:00:00Z",
                  updated_at: "2024-01-01T00:00:00Z",
                  created_by: "Teacher Name"
                }
              ]
            }
          }
        },
        create: {
          method: "POST",
          url: "/api/v1/students",
          description: "Create a new student",
          parameters: {
            name: "Student name (required)",
            reading: "Reading score 0-10 (required)",
            writing: "Writing score 0-10 (required)",
            listening: "Listening score 0-10 (required)",
            speaking: "Speaking score 0-10 (required)"
          },
          example_request: {
            student: {
              name: "Jane Smith",
              reading: 9,
              writing: 8,
              listening: 7,
              speaking: 9
            }
          }
        },
        update: {
          method: "PUT/PATCH",
          url: "/api/v1/students/:id",
          description: "Update student information",
          parameters: {
            name: "Student name (optional)",
            reading: "Reading score 0-10 (optional)",
            writing: "Writing score 0-10 (optional)",
            listening: "Listening score 0-10 (optional)",
            speaking: "Speaking score 0-10 (optional)"
          }
        },
        destroy: {
          method: "DELETE",
          url: "/api/v1/students/:id",
          description: "Delete a student"
        },
        stats: {
          method: "GET",
          url: "/api/v1/students/stats",
          description: "Get student statistics",
          example_response: {
            stats: {
              total_students: 25,
              average_score: 28.5,
              average_percentage: 71.25,
              top_performer: "Alice Johnson",
              skills_average: {
                reading: 7.2,
                writing: 6.8,
                listening: 7.5,
                speaking: 7.0
              },
              score_distribution: {
                excellent: 5,
                good: 8,
                average: 7,
                below_average: 3,
                needs_improvement: 2
              }
            }
          }
        }
      },
      notes: {
        index: {
          method: "GET",
          url: "/api/v1/students/:student_id/notes",
          description: "Get notes for a student",
          parameters: {
            search: "Search in note content (optional)",
            my_notes: "Show only my notes (true/false, optional)",
            page: "Page number (optional)",
            per_page: "Items per page (optional)"
          }
        },
        show: {
          method: "GET",
          url: "/api/v1/students/:student_id/notes/:id",
          description: "Get note details"
        },
        create: {
          method: "POST",
          url: "/api/v1/students/:student_id/notes",
          description: "Create a new note",
          parameters: {
            content: "Note content (required, max 1000 characters)"
          }
        },
        update: {
          method: "PUT/PATCH",
          url: "/api/v1/students/:student_id/notes/:id",
          description: "Update a note"
        },
        destroy: {
          method: "DELETE",
          url: "/api/v1/students/:student_id/notes/:id",
          description: "Delete a note"
        }
      }
    }
  end

  private

  def check_admin_access
    unless current_user.admin?
      redirect_to root_path, alert: "You do not have permission to access API documentation."
    end
  end
end
