class Investment < ApplicationRecord
  has_many :snapshots, dependent: :destroy
  has_one_attached :logo
  attr_accessor :remove_logo

  SECTORS = %w[fintech saas_b2b health deeptech marketplace consumer other].freeze
  STAGES  = %w[pre_seed seed series_a series_b growth].freeze

  enum :status, { active: "active", exited: "exited", written_off: "written_off" }
  enum :vehicle, { direct: "direct", pea_pme: "pea_pme", holding: "holding" }

  validates :company_name,    presence: true
  validates :invested_amount, presence: true, numericality: { greater_than: 0 }
  validates :investment_date, presence: true
  validates :equity_percentage,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
    allow_nil: true
  validates :sector,      inclusion: { in: SECTORS }, allow_nil: true
  validates :stage,       inclusion: { in: STAGES },  allow_nil: true
  validates :exit_date,   presence: true, if: -> { exit_amount.present? }
  validates :exit_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :acceptable_logo

  after_save :purge_logo_if_requested

  # ---------- Instance methods ----------

  def latest_snapshot
    snapshots.order(snapshot_date: :desc).first
  end

  def current_valuation
    return exit_amount if realized_exit?
    latest_snapshot&.current_valuation || (written_off? ? nil : invested_amount)
  end

  def multiple
    val = current_valuation
    return nil if val.nil?
    return nil if invested_amount.zero?
    val / invested_amount
  end

  def realized_exit?
    exited? && exit_amount.present?
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
    where(status: %w[active exited]).includes(:snapshots).sum do |inv|
      inv.current_valuation || 0
    end
  end

  def self.tvpi
    invested = total_invested
    return 0 if invested.zero?
    total_estimated_value / invested
  end

  def self.portfolio_irr
    cash_flows = []

    all.includes(:snapshots).each do |inv|
      cash_flows << [ inv.investment_date, -inv.invested_amount.to_f ]

      if inv.realized_exit?
        cash_flows << [ inv.exit_date, inv.exit_amount.to_f ]
      elsif inv.active?
        val = inv.latest_snapshot&.current_valuation || inv.invested_amount
        cash_flows << [ Date.today, val.to_f ]
      end
      # written_off → perte totale, pas de flux terminal
    end

    return nil if cash_flows.size < 2

    base_date = cash_flows.min_by(&:first).first
    flows = cash_flows.map { |date, amount| [ (date - base_date).to_f / 365.25, amount ] }

    return nil if flows.all? { |t, _| t.zero? }

    npv = ->(r) { flows.sum { |t, cf| cf / (1.0 + r)**t } }

    low, high = -0.9999, 10.0
    return nil if npv.call(low) * npv.call(high) > 0

    200.times do
      mid = (low + high) / 2.0
      npv.call(mid) > 0 ? low = mid : high = mid
      break if high - low < 0.00001
    end

    (low + high) / 2.0
  end

  def self.runway_alerts_count
    active.includes(:snapshots).count(&:runway_alert?)
  end

  private

  def acceptable_logo
    return unless logo.attached?

    unless logo.content_type.in?(%w[image/png image/jpeg image/webp])
      errors.add(:logo, "doit être une image PNG, JPEG ou WebP")
    end

    if logo.byte_size > 2.megabytes
      errors.add(:logo, "ne doit pas dépasser 2 Mo")
    end
  end

  def purge_logo_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(remove_logo)

    logo.purge_later if logo.attached?
  end
end
