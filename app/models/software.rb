class Software < ApplicationRecord
  has_many :node_services
  has_and_belongs_to_many :nodes

  def to_s
    name
  end

  def self.get_tech_from_open_port(service_name, port)
  end

  def self.clear_service_name(str)
    case str
    when /^node /
      "node"
    when /python/
      "python"
    when /in\/apach/
      "apache"
    when "apache2"
      "apache"
    else
      str
    end
  end
end
