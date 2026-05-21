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
end
