class NodeIp < ApplicationRecord
  belongs_to :node

  def ip_to_s
    IPAddr.new(ip.to_i, Socket::AF_INET).to_s
  end

  def network
    ip_to_s.gsub(/\.\d+$/, "")
  end
end
