class NodePolicy < ApplicationPolicy
  def update?
    @user.is_cesia? || @user.roles.include?(@record.role)
  end
end
