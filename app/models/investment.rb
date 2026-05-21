class Investment < ApplicationRecord
  has_many :snapshots, dependent: :destroy

  SECTORS = %w[fintech saas_b2b health deeptech marketplace consumer other].freeze
  STAGES  = %w[pre_seed seed series_a series_b growth].freeze

  enum :status, { active: "active", exited: "exited", written_off: "written_off" }

  validates :company_name,    presence: true
  validates :invested_amount, presence: true, numericality: { greater_than: 0 }
  validates :investment_date, presence: true
  validates :equity_percentage,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
    allow_nil: true
  validates :sector, inclusion: { in: SECTORS }, allow_nil: true
  validates :stage,  inclusion: { in: STAGES },  allow_nil: true

  # ---------- Instance methods ----------

  def latest_snapshot
    snapshots.order(snapshot_date: :desc).first
  end

  def current_valuation
    latest_snapshot&.current_valuation
  end

  def multiple
    val = current_valuation
    return nil if val.nil?
    return nil if invested_amount.zero?
    val / invested_amount
  end

  def runway_alert?
    months = latest_snapshot&.runway_months
    months.present? && months < 6
  end

  # ---------- Class methods ----------

  def self.total_invested
    sum(:invested_amount)
  end

  def self.total_estimated_value
    latest = Snapshot
      .select("DISTINCT ON (investment_id) investment_id, COALESCE(current_valuation, 0) AS current_valuation")
      .order("investment_id, snapshot_date DESC")

    joins("INNER JOIN (#{latest.to_sql}) AS latest_snaps ON latest_snaps.investment_id = investments.id")
      .where(status: %w[active exited])
      .sum("latest_snaps.current_valuation")
  end

  def self.tvpi
    invested = total_invested
    return 0 if invested.zero?
    total_estimated_value / invested
  end

  def self.runway_alerts_count
    active.includes(:snapshots).count(&:runway_alert?)
  end
end
