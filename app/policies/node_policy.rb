class NodePolicy < ApplicationPolicy
  def update?
    @user.is_cesia?
  end
end
