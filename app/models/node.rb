class Node < ApplicationRecord
  belongs_to :role
  has_and_belongs_to_many :agreements
  has_many :node_services, dependent: :destroy
  has_many :node_ips, dependent: :destroy
  has_many :ssh_logins, dependent: :destroy

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

  def update_ip_association_from_s(ip)
    ip = IPAddr.new(ip).to_i
    n = node_ips.find_or_create_by!(ip: ip)
    n.update(updated_at: Time.now) unless n.new_record?
  end

  def web_sites
    WebSiteAddress.where(ip: node_ips.map(&:ip)).map { |w| w.web_site }
  end

  def zabbix_page
    "https://zabbix.unibo.it/zabbix.php?name=#{name}&ip=&dns=&port=&status=-1&evaltype=0&tags%5B0%5D%5Btag%5D=&tags%5B0%5D%5Boperator%5D=0&tags%5B0%5D%5Bvalue%5D=&maintenance_status=1&filter_name=&filter_show_counter=0&filter_custom_time=0&sort=name&sortorder=ASC&show_suppressed=0&action=host.view"
  end
end
