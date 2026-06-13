class SharesController < ApplicationController
  layout "shared"
  skip_before_action :authenticate_user!
  before_action :load_share_user!
  before_action :require_valid_share!, only: [ :dashboard, :investment, :sign_out ]

  rate_limit to: 5, within: 1.minute, only: :unlock,
             with: -> { redirect_to share_path(params[:token]),
                                    alert: "Trop de tentatives, réessaie dans 1 minute." }

  def show
    return redirect_to share_dashboard_path(params[:token]) if session_valid?
    render :show
  end

  def unlock
    if @share_user.authenticate_share_password(params[:password])
      session[:share_token] = @share_user.share_token
      redirect_to share_dashboard_path(@share_user.share_token)
    else
      redirect_to share_path(params[:token]),
                  alert: "Mot de passe invalide."
    end
  end

  def dashboard
    @total_invested        = Investment.total_invested
    @total_estimated_value = Investment.total_estimated_value
    @tvpi                  = Investment.tvpi
    @irr                   = Investment.portfolio_irr
    @runway_alerts_count   = Investment.runway_alerts_count
    @active_count          = Investment.active.count
    @exited_count          = Investment.exited.count
    @written_off_count     = Investment.written_off.count
    @sector_breakdown      = Investment.where.not(sector: nil).group(:sector).sum(:invested_amount)
    @stage_breakdown       = Investment.where.not(stage: nil).group(:stage).sum(:invested_amount)
    @investments           = Investment.with_attached_logo.order(investment_date: :desc)
  end

  def investment
    @investment      = Investment.find(params[:id])
    @snapshots       = @investment.snapshots.order(snapshot_date: :desc)
    @latest_snapshot = @investment.latest_snapshot
  end

  def sign_out
    session.delete(:share_token)
    redirect_to share_path(params[:token])
  end

  private

  def load_share_user!
    @share_user = User.find_by(share_token: params[:token])
    head :not_found unless @share_user
  end

  def require_valid_share!
    head :not_found unless session_valid?
  end

  def session_valid?
    session[:share_token].present? && session[:share_token] == params[:token]
  end
end
