class SoftwaresController < ApplicationController
  def index
    authorize :software
    @softwares = Software.order(:name).includes(node_services: :node).all
  end
end
