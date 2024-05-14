class Software < ApplicationRecord
  has_many :node_services
  has_and_belongs_to_many :nodes

  def to_s
    name
  end

  def self.get_tech_from_open_port(service_name, port)
  end
end
