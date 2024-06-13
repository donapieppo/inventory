class AdGroupsController < ApplicationController
  def index
    authorize :ad_groups
    @ad_groups = AdGroup.includes([:roles, :users]).order(:name)
  end

  def show
    @ad_group = AdGroup.find(params[:id])
    authorize @ad_group
  end
end
