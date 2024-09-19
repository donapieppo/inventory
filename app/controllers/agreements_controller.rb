class AgreementsController < ApplicationController
  before_action :set_agreement_and_authorize, only: %i[show edit update destroy]

  def index
    authorize :agreement
    @agreements = Agreement.order(:start_date).includes(:projects).all
  end

  def show
    @projects = @agreement.projects.order(:name).includes(:nodes)
  end

  def new
    @agreement = Agreement.new
    authorize @agreement
  end

  def edit
  end

  def create
    @agreement = Agreement.new(agreement_params)
    authorize @agreement

    if @agreement.save
      redirect_to [:edit, @agreement], notice: "Agreement was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @agreement.update(agreement_params)
      redirect_to @agreement, notice: "Agreement was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agreement.destroy!
    redirect_to agreements_url, notice: "Agreement was successfully destroyed.", status: :see_other
  end

  private

  def set_agreement_and_authorize
    @agreement = Agreement.find(params[:id])
    authorize @agreement
  end

  def agreement_params
    params.require(:agreement).permit(:external, :party, :referent, :referent_contact, :name, :description, :amount, :start_date, :end_date, project_ids: [])
  end
end
