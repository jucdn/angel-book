require "rails_helper"

RSpec.describe Snapshot, type: :model do
  describe "associations" do
    it "belongs to an investment" do
      expect(build(:snapshot).investment).to be_a(Investment)
    end
  end

  describe "validations" do
    it "is valid with required attributes" do
      expect(build(:snapshot)).to be_valid
    end

    it "is invalid without snapshot_date" do
      expect(build(:snapshot, snapshot_date: nil)).not_to be_valid
    end

    it "is invalid without investment" do
      expect(build(:snapshot, investment: nil)).not_to be_valid
    end

    it "is invalid with negative mrr" do
      expect(build(:snapshot, mrr: -100)).not_to be_valid
    end

    it "is invalid with negative runway_months" do
      expect(build(:snapshot, runway_months: -1)).not_to be_valid
    end
  end
end
