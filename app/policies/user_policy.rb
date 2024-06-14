class UserPolicy < ApplicationPolicy
  def show?
    @user.is_cesia?
  end

  def create?
    @user.is_cesia?
  end
end
