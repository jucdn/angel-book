require "rails_helper"

RSpec.describe User, type: :model do
  describe "#share_enabled?" do
    it "is false when no token is set" do
      expect(build(:user, share_token: nil).share_enabled?).to be(false)
    end

    it "is true when a token is set" do
      expect(build(:user, share_token: "abc").share_enabled?).to be(true)
    end
  end

  describe "#regenerate_share!" do
    let(:user) { create(:user) }

    it "sets a urlsafe token and a verifiable password" do
      user.regenerate_share!(password: "long-enough-password")

      expect(user.share_token).to be_present
      expect(user.share_token.length).to be >= 40
      expect(user.authenticate_share_password("long-enough-password")).to eq(user)
      expect(user.authenticate_share_password("wrong")).to be(false)
    end

    it "rejects passwords shorter than 12 characters" do
      expect {
        user.regenerate_share!(password: "short")
      }.to raise_error(ActiveRecord::RecordInvalid, /Share password/)
    end

    it "produces a different token on each call" do
      user.regenerate_share!(password: "long-enough-password")
      first = user.share_token
      user.regenerate_share!(password: "another-long-password")
      expect(user.share_token).not_to eq(first)
    end
  end

  describe "#revoke_share!" do
    it "nullifies token and digest" do
      user = create(:user)
      user.regenerate_share!(password: "long-enough-password")
      user.revoke_share!

      expect(user.share_token).to be_nil
      expect(user.share_password_digest).to be_nil
    end
  end
end
