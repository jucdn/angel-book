FactoryBot.define do
  factory :investment do
    company_name      { Faker::Company.name }
    sector            { "saas_b2b" }
    stage             { "seed" }
    invested_amount   { 25_000 }
    entry_valuation   { 2_000_000 }
    equity_percentage { 1.25 }
    investment_date   { 2.years.ago.to_date }
    status            { "active" }
    website           { Faker::Internet.url }
    description       { Faker::Lorem.sentence }
  end
end
