class SoftwaresController < ApplicationController
  def index
    authorize :software
    @softwares = Software.order(:name)
  end

  def show
    @software = Software.find(params[:id])
    authorize @software
  end
end
