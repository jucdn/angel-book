class Snapshot < ApplicationRecord
  belongs_to :investment

  validates :snapshot_date, presence: true
  validates :current_valuation,
    numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :mrr,
    numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :arr,
    numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :runway_months,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :headcount,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :last_round_amount,
    numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :recent_first, -> { order(snapshot_date: :desc) }
end
