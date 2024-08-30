class NodeIpsController < ApplicationController
  def index
    authorize :node_ip
    @node_ips = NodeIp.order(:ip).includes(:node)
  end
end
