# == Schema Information
# Schema version: 20251125143906
#
# Table name: telegram_links
#
#  id                :bigint           not null, primary key
#  active            :boolean          default(TRUE)
#  telegram_username :string
#  verification_code :string
#  verified          :boolean          default(FALSE)
#  verified_at       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  telegram_user_id  :string           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_telegram_links_on_telegram_user_id    (telegram_user_id) UNIQUE
#  index_telegram_links_on_user_id             (user_id)
#  index_telegram_links_on_user_id_and_active  (user_id,active)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class TelegramLink < ApplicationRecord
  belongs_to :user
  
  validates :telegram_user_id, presence: true, uniqueness: true
  validates :telegram_username, length: { maximum: 100 }, allow_blank: true
  
  before_create :generate_verification_code
  
  scope :active, -> { where(active: true) }
  scope :verified, -> { where(verified: true) }
  scope :pending_verification, -> { where(verified: false) }
  
  def verify!(code)
    if verification_code == code
      update!(
        verified: true,
        verified_at: Time.current,
        verification_code: nil
      )
      true
    else
      false
    end
  end
  
  def regenerate_verification_code!
    generate_verification_code
    save!
  end
  
  private
  
  def generate_verification_code
    self.verification_code = SecureRandom.alphanumeric(6).upcase
  end
end
