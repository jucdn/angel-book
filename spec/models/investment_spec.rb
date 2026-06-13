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

  describe "vehicle enum" do
    it "defaults to direct" do
      expect(build(:investment).vehicle).to eq("direct")
    end

    it "accepts direct, pea_pme, and holding" do
      %w[direct pea_pme holding].each do |v|
        inv = build(:investment, vehicle: v)
        expect(inv).to be_valid
        expect(inv.vehicle).to eq(v)
      end
    end

    it "raises ArgumentError on unknown vehicle" do
      expect { build(:investment, vehicle: "crypto_dao") }.to raise_error(ArgumentError)
    end

    it "exposes scope and predicate methods" do
      inv = create(:investment, vehicle: "pea_pme")
      expect(inv).to be_pea_pme
      expect(Investment.pea_pme).to include(inv)
    end
  end

  describe "instance methods" do
    let(:investment) { create(:investment, invested_amount: 50_000) }

    describe "#latest_snapshot" do
      it "returns the most recent snapshot by date" do
        create(:snapshot, investment: investment, snapshot_date: 1.year.ago.to_date, current_valuation: 40_000)
        recent = create(:snapshot, investment: investment, snapshot_date: 1.month.ago.to_date, current_valuation: 80_000)
        expect(investment.latest_snapshot).to eq(recent)
      end

      it "returns nil when there are no snapshots" do
        expect(investment.latest_snapshot).to be_nil
      end
    end

    describe "#current_valuation" do
      it "returns current_valuation from the latest snapshot" do
        create(:snapshot, investment: investment, snapshot_date: Date.today, current_valuation: 90_000)
        expect(investment.current_valuation).to eq(90_000)
      end

      it "returns invested_amount with no snapshots (active investment)" do
        expect(investment.current_valuation).to eq(investment.invested_amount)
      end

      it "returns nil with no snapshots for a written_off investment" do
        investment.update!(status: "written_off")
        expect(investment.current_valuation).to be_nil
      end
    end

    describe "#multiple" do
      it "calculates current_valuation / invested_amount" do
        create(:snapshot, investment: investment, snapshot_date: Date.today, current_valuation: 150_000)
        expect(investment.multiple).to be_within(0.01).of(3.0)
      end

      it "returns 1.0 with no snapshots (falls back to invested_amount)" do
        expect(investment.multiple).to be_within(0.01).of(1.0)
      end
    end

    describe "#runway_alert?" do
      it "returns true when runway_months < 6" do
        create(:snapshot, investment: investment, snapshot_date: Date.today, runway_months: 4)
        expect(investment.runway_alert?).to be true
      end

      it "returns false when runway_months >= 6" do
        create(:snapshot, investment: investment, snapshot_date: Date.today, runway_months: 12)
        expect(investment.runway_alert?).to be false
      end

      it "returns false when runway is nil" do
        create(:snapshot, investment: investment, snapshot_date: Date.today, runway_months: nil)
        expect(investment.runway_alert?).to be false
      end
    end
  end

  describe "class methods" do
    before do
      @inv_active = create(:investment, invested_amount: 50_000, status: "active")
      create(:snapshot, investment: @inv_active, snapshot_date: Date.today, current_valuation: 120_000)

      @inv_exited = create(:investment, invested_amount: 30_000, status: "exited")
      create(:snapshot, investment: @inv_exited, snapshot_date: 1.month.ago.to_date, current_valuation: 90_000)

      @inv_woff = create(:investment, invested_amount: 20_000, status: "written_off")
    end

    describe ".total_invested" do
      it "sums invested_amount across all statuses" do
        expect(Investment.total_invested).to eq(100_000)
      end
    end

    describe ".total_estimated_value" do
      it "sums latest current_valuation for active and exited only" do
        expect(Investment.total_estimated_value).to eq(210_000)
      end

      it "excludes written_off investments" do
        expect(Investment.total_estimated_value).to eq(210_000)
      end
    end

    describe ".tvpi" do
      it "divides total_estimated_value by total_invested" do
        expect(Investment.tvpi).to be_within(0.01).of(2.1)
      end

      it "returns 0 when nothing is invested" do
        Investment.destroy_all
        expect(Investment.tvpi).to eq(0)
      end
    end

    describe ".runway_alerts_count" do
      it "counts active investments with latest runway < 6 months" do
        create(:snapshot, investment: @inv_active, snapshot_date: Date.today + 1, runway_months: 4)
        expect(Investment.runway_alerts_count).to eq(1)
      end

      it "does not count exited investments" do
        create(:snapshot, investment: @inv_exited, snapshot_date: Date.today + 1, runway_months: 3)
        expect(Investment.runway_alerts_count).to eq(0)
      end
    end
  end

  describe "logo attachment" do
    let(:investment) { build(:investment) }

    def attach(io:, filename:, content_type:)
      investment.logo.attach(io: io, filename: filename, content_type: content_type)
    end

    it "accepts a valid PNG logo" do
      attach(
        io: Rails.root.join("spec/fixtures/files/logo.png").open,
        filename: "logo.png",
        content_type: "image/png"
      )
      expect(investment).to be_valid
      expect(investment.logo).to be_attached
    end

    it "rejects a non-image content type" do
      attach(
        io: StringIO.new("not an image"),
        filename: "doc.pdf",
        content_type: "application/pdf"
      )
      expect(investment).not_to be_valid
      expect(investment.errors[:logo]).to include("doit être une image PNG, JPEG ou WebP")
    end

    it "rejects a logo larger than 2 Mo" do
      attach(
        io: StringIO.new("a" * 3.megabytes),
        filename: "big.png",
        content_type: "image/png"
      )
      expect(investment).not_to be_valid
      expect(investment.errors[:logo]).to include("ne doit pas dépasser 2 Mo")
    end

    it "purges the logo when remove_logo is set" do
      investment.save!
      investment.logo.attach(
        io: Rails.root.join("spec/fixtures/files/logo.png").open,
        filename: "logo.png",
        content_type: "image/png"
      )
      investment.save!
      expect(investment.logo).to be_attached

      investment.update!(remove_logo: "1")
      expect(investment.reload.logo).not_to be_attached
    end
  end
end
