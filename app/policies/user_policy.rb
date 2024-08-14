class UserPolicy < ApplicationPolicy
  def show?
    @user
  end

  def create?
    @user.is_cesia?
  end
end
