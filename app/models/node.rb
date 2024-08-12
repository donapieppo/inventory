class Node < ApplicationRecord
  belongs_to :role
  has_many :node_services
  has_many :node_ips
  has_many :ssh_logins

  validates :name, uniqueness: true

  def to_s
    name
  end

  def to_s_short
    name.gsub(".personale.dir.unibo.it", "")
  end

  def data_file
    Rails.configuration.puppet_repo_dir + "/data/nodes/#{name}.yaml"
  end

  def update_ip_association(ip)
    n = node_ips.find_or_create_by!(ip: ip)
    n.update(updated_at: Time.now) unless n.new_record?
  end

  def web_sites
    WebSiteAddress.where(ip: node_ips.map(&:ip)).map { |w| w.web_site }
  end
end
