FactoryBot.define do
  factory :snapshot do
    association :investment
    snapshot_date     { Date.today }
    current_valuation { 50_000 }
    mrr               { 8_000 }
    arr               { 96_000 }
    runway_months     { 18 }
    headcount         { 5 }
    last_round_amount { nil }
    last_round_date   { nil }
    notes             { nil }
  end
end
