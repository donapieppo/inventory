# frozen_string_literal: true

class Role::ProjectsComponent < ViewComponent::Base
  def initialize(role)
    @role = role
    @projects = @role.projects.order(:name).all
  end
end
