module ApplicationHelper
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

include DmUniboCommonHelper
