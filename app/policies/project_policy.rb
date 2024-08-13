class ProjectPolicy < ApplicationPolicy
  def create?
    @user.is_cesia?
  end

  def update?
    @user.is_cesia? || @user.project_ids.include?(@record.id)
  end
end
