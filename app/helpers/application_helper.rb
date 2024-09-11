include DmUniboCommonHelper

module ApplicationHelper
  def project_color(project, user_project)
    if user_project
      "bg-warning"
    elsif project.agreements.any?
      "bg-info"
    else
      "bg-light"
    end
  end

  def web_site_state_color(web_site)
    case web_site.state
    when "down"
      "danger"
    when "unhealthy"
      "warning"
    else
      ""
    end
  end
end
