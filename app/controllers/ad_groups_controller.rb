class AdGroupsController < ApplicationController
  def index
    @ad_groups = AdGroup.includes([:roles, :users]).order(:name)
  end

  def show
    @ad_group = AdGroup.find(params[:id])
  end
end
