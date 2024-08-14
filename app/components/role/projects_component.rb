# frozen_string_literal: true

class Role::ProjectsComponent < ViewComponent::Base
  def initialize(current_user, role)
    @role = role
    @projects = @role.projects.order(:name).all
    @role_policy = RolePolicy.new(current_user, @role)
  end
end
