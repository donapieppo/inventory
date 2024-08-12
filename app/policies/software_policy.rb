class SoftwarePolicy < ApplicationPolicy
  def index?
    @user
  end
end
