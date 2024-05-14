class NodeService < ApplicationRecord
  belongs_to :node
  belongs_to :software

  def to_s
    "#{software.name} on #{node.name} port #{port}"
  end
end
