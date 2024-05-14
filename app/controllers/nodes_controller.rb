class NodesController < ApplicationController
  before_action :set_node, only: %i[ show edit update destroy ]

  # GET /nodes
  def index
    @nodes = Node.order(:name).includes(:role).all
  end

  # GET /nodes/1
  def show
  end

  # GET /nodes/new
  def new
    @node = Node.new
  end

  # GET /nodes/1/edit
  def edit
  end

  # POST /nodes
  def create
    @node = Node.new(node_params)

    if @node.save
      redirect_to @node, notice: "Node was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /nodes/1
  def update
    if @node.update(node_params)
      redirect_to @node, notice: "Node was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /nodes/1
  def destroy
    @node.destroy!
    redirect_to nodes_url, notice: "Node was successfully destroyed.", status: :see_other
  end

  private

  def set_node
    @node = Node.find(params[:id])
  end

  def node_params
    params.require(:node).permit(:name, :notes)
  end
end
