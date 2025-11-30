# == Schema Information
# Schema version: 20251125143906
#
# Table name: notifications
#
#  id         :bigint           not null, primary key
#  body       :text
#  data       :jsonb
#  read_at    :datetime
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_notifications_on_created_at           (created_at)
#  index_notifications_on_user_id              (user_id)
#  index_notifications_on_user_id_and_read_at  (user_id,read_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(50) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def unread?
    !read?
  end
end
