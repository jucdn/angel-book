class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable

  has_secure_password :share_password, validations: false

  validates :share_password,
            length: { minimum: 12 },
            allow_nil: true

  def share_enabled?
    share_token.present?
  end

  def regenerate_share!(password:)
    self.share_token = SecureRandom.urlsafe_base64(32)
    self.share_password = password
    save!
  end

  def revoke_share!
    update!(share_token: nil, share_password_digest: nil)
  end
end
