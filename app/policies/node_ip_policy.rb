class NodeIpPolicy < ApplicationPolicy
  def index?
    @user
  end
end
