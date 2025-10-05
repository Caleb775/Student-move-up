module ApplicationHelper
  def role_badge_class(role)
    case role
    when 0 # student
      "bg-secondary"
    when 1 # teacher
      "bg-primary"
    when 2 # admin
      "bg-danger"
    else
      "bg-light text-dark"
    end
  end

  def percentage_badge_class(percentage)
    case percentage
    when 90..100
      "bg-success"
    when 80..89
      "bg-primary"
    when 70..79
      "bg-warning"
    when 60..69
      "bg-info"
    else
      "bg-danger"
    end
  end

  def notification_icon(notification_type)
    case notification_type
    when "student_created"
      content_tag(:i, "", class: "bi bi-person-plus student-created")
    when "student_updated"
      content_tag(:i, "", class: "bi bi-person-check student-updated")
    when "note_added"
      content_tag(:i, "", class: "bi bi-sticky note-added")
    when "weekly_report"
      content_tag(:i, "", class: "bi bi-graph-up weekly-report")
    when "welcome"
      content_tag(:i, "", class: "bi bi-hand-thumbs-up welcome")
    when "system_announcement"
      content_tag(:i, "", class: "bi bi-megaphone system-announcement")
    else
      content_tag(:i, "", class: "bi bi-bell")
    end
  end
end
