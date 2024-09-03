class WebSiteAddress < ApplicationRecord
  belongs_to :web_site

  def ip_to_s
    IPAddr.new(ip.to_i, Socket::AF_INET).to_s
  end
end
