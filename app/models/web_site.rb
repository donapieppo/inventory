class WebSite < ApplicationRecord
  has_many :web_site_addresses

  def to_s
    name
  end

  def url
    "https://#{name}"
  end
end
