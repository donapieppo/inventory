class WebSite < ApplicationRecord
  has_many :web_site_addresses

  def to_s
    name
  end

  def url
    "https://#{name}"
  end

  def update_ip_association_from_s(ip, port)
    ip = IPAddr.new(ip).to_i
    w = web_site_addresses.find_or_create_by!(ip: ip, port: port.to_i)
    w.update(updated_at: Time.now) unless w.new_record?
  end
end
