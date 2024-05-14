class Node < ApplicationRecord
  belongs_to :role
  has_many :node_services

  def to_s
    name
  end

  def data_file
    "/home/dona/puppet-control-repo/data/nodes/#{name}.yaml"
  end
end
