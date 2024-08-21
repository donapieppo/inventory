class SoftwarePolicy < ApplicationPolicy
  def index?
    @user
  end

  def show?
    @user
  end
end
