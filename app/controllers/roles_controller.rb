class RolesController < ApplicationController
  before_action :get_role_and_check_permission, only: [:show, :edit, :update]

  def index
    @roles = Role.order(:name)
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

  private

  def get_role_and_check_permission
    @role = Role.includes(:nodes).find(params[:id])
  end

  def role_params
    params.require(:role).permit(:description)
  end
end
