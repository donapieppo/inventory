class NodesController < ApplicationController
  before_action :set_node_and_authorize, only: %i[show edit update]

  # GET /nodes
  def index
    authorize :node
    @nodes = Node.order(:name).includes(:role).all
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
    params.require(:node).permit(:name, :notes)
  end
end
