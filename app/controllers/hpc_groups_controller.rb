class HpcGroupsController < ApplicationController
  before_action :set_hpc_group_and_check_permission, only: %i[show edit update]

  def index
    @hpc_groups = HpcGroup.order(:name).all
  end

  def show
  end

  def new
    @hpc_group = HpcGroup.new
  end

  def create
    @hpc_group = Project.new(hpc_group_params)

    if @hpc_group.save
      redirect_to @hpc_group, notice: "HPC group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @hpc_group.update(hpc_group_params)
      redirect_to @hpc_group, notice: "HPC group was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_hpc_group_and_check_permission
    @hpc_group = HpcGroup.find(params[:id])
  end

  def hpc_group_params
    params.require(:hpc_group).permit(:name, :description)
  end
end
