class RolesController < ApplicationController
  before_action :get_role_and_authorize, only: [:show, :edit, :update, :choose_project, :set_projects]

  def index
    authorize :role
    @roles = Role.includes(:projects).order(:name)
  end

  def show
  end

  def edit
  end

  def update
    if @role.update(role_params)
      redirect_to @role, notice: "Role was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def choose_project
  end

  def set_projects
    @role.project_ids = params[:role][:project_ids]
    @role.save
  end

  private

  def get_role_and_authorize
    @role = Role.includes(:nodes).find(params[:id])
    authorize @role
  end

  def role_params
    params.require(:role).permit(:description)
  end
end
