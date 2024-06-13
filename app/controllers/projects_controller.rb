class ProjectsController < ApplicationController
  before_action :set_project_and_authorize, only: %i[show edit update destroy]

  def index
    authorize :project
    @projects = Project.all
  end

  def show
    @roles = @project.roles.order(:name).includes(:nodes)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def edit
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      redirect_to @project, notice: "Project was successfully created."
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
    params.require(:project).permit(:name, :description, role_ids: [])
  end
end
