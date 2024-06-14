class WebSitesController < ApplicationController
  def index
    authorize :web_site
    @web_sites = WebSite.order(:name)
  end

  def show
    @web_site = WebSite.find(params[:id])
    authorize @web_site
  end
end
