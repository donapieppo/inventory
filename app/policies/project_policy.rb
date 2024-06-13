class ProjectPolicy < ApplicationPolicy
  def create?
    @user.is_cesia?
  end

  def update?
    @user.is_cesia?
  end
end
