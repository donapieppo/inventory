class RolePolicy < ApplicationPolicy
  def create?
    @user.is_cesia?
  end

  def update?
    @user.is_cesia? || @user.roles.include?(@record)
  end

  def choose_project?
    update?
  end

  def set_projects?
    update?
  end
end
