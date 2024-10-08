class NodesController < ApplicationController
  before_action :set_node_and_authorize, only: %i[show edit update]

  # GET /nodes
  def index
    authorize :node
    @nodes = Node.order(:name).includes(:role)
    if params[:os] && params[:os_version]
      @nodes = @nodes.where("operatingsystem = ? and operatingsystemrelease <= ?", params[:os], params[:os_version])
    end
  end

  def analysis
    authorize :node
    @versions = Node.select(:operatingsystem, :operatingsystemrelease).order(:operatingsystem, :operatingsystemrelease).distinct
    if params[:os] && params[:os_version]
      @title = " #{params[:os]} versione #{params[:os_version]}"
      @nodes = Node.includes(:role, :node_ips, ssh_logins: :user).order("roles.name").where("operatingsystem = ? and operatingsystemrelease = ?", params[:os], params[:os_version])
    else
      @nodes = Node.none
    end
  end

  def show
  end

  def edit
  end

  def update
    if @node.update(node_params)
      redirect_to @node, notice: "Node was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_node_and_authorize
    @node = Node.find(params[:id])
    authorize @node
  end

  def node_params
    params.require(:node).permit(:notes)
  end
end
