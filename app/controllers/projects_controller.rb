class ProjectsController < ApplicationController
  before_action :set_project_and_authorize, only: %i[show edit update destroy]

  def index
    authorize :project
    @projects = Project.order(:name).includes(:users, :agreements).load
    # @my_projects = Project.order(:name).where(user_id: current_user.id)
  end

  def show
    @roles = @project.roles.order(:name).includes(:nodes)
    @users = @project.users.order(:upn)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def edit
    @what = params[:what]
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      redirect_to [:edit, @project], notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!
    redirect_to projects_url, notice: "Project was successfully destroyed.", status: :see_other
  end

  private

  def set_project_and_authorize
    @project = Project.find(params[:id])
    authorize @project
  end

  def project_params
    p = [:name, :description, role_ids: []]
    p << {user_ids: []} if current_user.is_cesia?
    params.require(:project).permit(p)
  end
end
