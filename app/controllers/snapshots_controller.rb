class SnapshotsController < ApplicationController
  before_action :set_investment
  before_action :set_snapshot, only: [ :destroy ]

  def new
    @snapshot = @investment.snapshots.new(snapshot_date: Date.today)
  end

  def create
    @snapshot = @investment.snapshots.new(snapshot_params)
    if @snapshot.save
      redirect_to @investment, notice: "Mise à jour enregistrée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @snapshot.destroy
    redirect_to @investment, notice: "Mise à jour supprimée."
  end

  private

  def set_investment
    @investment = Investment.find(params[:investment_id])
  end

  def set_snapshot
    @snapshot = @investment.snapshots.find(params[:id])
  end

  def snapshot_params
    params.require(:snapshot).permit(
      :snapshot_date, :current_valuation, :mrr, :arr,
      :runway_months, :headcount, :last_round_amount,
      :last_round_date, :notes
    )
  end
end
