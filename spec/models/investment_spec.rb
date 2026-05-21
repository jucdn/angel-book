require "rails_helper"

RSpec.describe Investment, type: :model do
  describe "validations" do
    it "is valid with required attributes" do
      expect(build(:investment)).to be_valid
    end

    it "is invalid without company_name" do
      expect(build(:investment, company_name: nil)).not_to be_valid
    end

    it "is invalid without invested_amount" do
      expect(build(:investment, invested_amount: nil)).not_to be_valid
    end

    it "is invalid without investment_date" do
      expect(build(:investment, investment_date: nil)).not_to be_valid
    end

    it "is invalid with negative invested_amount" do
      expect(build(:investment, invested_amount: -100)).not_to be_valid
    end
  end

  describe "enums" do
    it "defaults status to active" do
      expect(build(:investment).status).to eq("active")
    end

    it "accepts valid sector values" do
      %w[fintech saas_b2b health deeptech marketplace consumer other].each do |s|
        expect(build(:investment, sector: s)).to be_valid
      end
    end

    it "rejects invalid sector" do
      expect(build(:investment, sector: "crypto")).not_to be_valid
    end

    it "accepts valid stage values" do
      %w[pre_seed seed series_a series_b growth].each do |s|
        expect(build(:investment, stage: s)).to be_valid
      end
    end
  end
end
