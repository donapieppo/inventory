class NodePolicy < ApplicationPolicy
  def analysis?
    index?
  end

  def update?
    @user.is_cesia? || @user.roles.include?(@record.role)
  end
end
