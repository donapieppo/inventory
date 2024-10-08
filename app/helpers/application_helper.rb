include DmUniboCommonHelper

module ApplicationHelper
  def project_color(project, user_project)
    if user_project
      "bg-secondary"
    elsif project.agreements.any?
      "bg-warning-subtle"
    else
      "bg-white"
    end
  end

  def web_site_state_color(web_site)
    case web_site.state
    when "down"
      "danger"
    when "unhealthy"
      "warning"
    else
      "success"
    end
  end

  def important_date_icon(date)
    case date.date_type
    when "alert"
      dm_icon("triangle-exclamation")
    when "memorandum"
      dm_icon("clipboard")
    else
      dm_icon("clipboard")
    end
  end

  def markdown(str)
    if str
      Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(str)
    end
  end

  def description_to_s(description)
    description.blank? ? dm_icon("triangle-exclamation", text: "Descrizione non ancora presente") : description
  end
end
