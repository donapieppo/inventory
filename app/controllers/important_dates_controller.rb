class ImportantDatesController < ApplicationController
  before_action :set_date_and_check_authorization, only: %i[show edit update destroy]

  def index
    authorize :important_date
    @dates = ImportantDate.all
  end

  def show
  end

  def new
    @what = get_what
    @date = ImportantDate.new
    authorize @date
  end

  def create
    @what = get_what
    @date = @what.important_dates.new(date_params)
    authorize @date
    if @date.save
      redirect_to @what, notice: "OK."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @what = @date.datable
  end

  def update
    @what = @date.datable
    if @date.update(date_params)
      redirect_to @what, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @date.destroy!
    redirect_to important_dates_path, notice: "Post was successfully destroyed."
  end

  private

  def get_what
    if params[:project_id]
      Project.find(params[:project_id])
    elsif params[:agreement_id]
      Agreement.find(params[:agreement_id])
    end
  end

  def set_date_and_check_authorization
    @date = ImportantDate.find(params[:id])
    authorize @date
  end

  def date_params
    params.require(:important_date).permit(:date_type, :date, :name, :description)
  end
end
