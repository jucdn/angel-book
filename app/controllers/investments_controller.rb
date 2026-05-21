class InvestmentsController < ApplicationController
  before_action :set_investment, only: [ :show, :edit, :update, :destroy, :exit_form, :record_exit ]

  def index
    @investments = Investment.all
    @investments = @investments.where(sector: params[:sector]) if params[:sector].present?
    @investments = @investments.where(status: params[:status]) if params[:status].present?
    if params[:q].present?
      @investments = @investments.where("company_name ILIKE ?", "%#{params[:q]}%")
    end
    @investments = @investments.order(investment_date: :desc)
  end

  def show
    @snapshots       = @investment.snapshots.order(snapshot_date: :desc)
    @latest_snapshot = @investment.latest_snapshot
  end

  def new
    @investment = Investment.new
  end

  def create
    @investment = Investment.new(investment_params)
    if @investment.save
      redirect_to @investment, notice: "Investissement créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @investment.update(investment_params)
      redirect_to @investment, notice: "Investissement mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def exit_form
  end

  def record_exit
    if @investment.update(exit_params.merge(status: "exited"))
      redirect_to @investment, notice: "Sortie enregistrée."
    else
      render :exit_form, status: :unprocessable_entity
    end
  end

  def destroy
    @investment.destroy
    redirect_to investments_path, notice: "Investissement supprimé."
  end

  private

  def set_investment
    @investment = Investment.find(params[:id])
  end

  def investment_params
    params.require(:investment).permit(
      :company_name, :sector, :stage, :invested_amount,
      :entry_valuation, :equity_percentage, :investment_date,
      :status, :website, :description
    )
  end

  def exit_params
    params.require(:investment).permit(:exit_date, :exit_amount)
  end
end
