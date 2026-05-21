class DashboardController < ApplicationController
  def index
    @total_invested        = Investment.total_invested
    @total_estimated_value = Investment.total_estimated_value
    @tvpi                  = Investment.tvpi
    @runway_alerts_count   = Investment.runway_alerts_count
    @active_count          = Investment.active.count
    @exited_count          = Investment.exited.count
    @written_off_count     = Investment.written_off.count
    @sector_breakdown      = Investment.where.not(sector: nil).group(:sector).sum(:invested_amount)
    @stage_breakdown       = Investment.where.not(stage: nil).group(:stage).sum(:invested_amount)
  end
end
