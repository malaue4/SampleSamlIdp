class User < ApplicationRecord

  has_many :user_sessions, dependent: :delete_all
  has_one :active_session, ->(user) {
    where(id: user.user_sessions.maximum(:id), expires_at: Time.current..)
  }, class_name: "UserSession"

  validates :name_id, presence: true

  has_one_attached :avatar
  validates :avatar, content_type: { with: %w[image/jpeg image/png image/gif], message: "must be a valid image" }

  has_secure_password

  before_create do
    self.notes ||= { password: }
  end

  # Avatar variant definitions
  def avatar_thumb
    avatar.variant(resize_to_fill: [ 100, 100 ]) if avatar.attached?
  end

  def avatar_medium
    avatar.variant(resize_to_fill: [ 300, 300 ]) if avatar.attached?
  end

  def persistent
    name_id
  end

  def active?
    expires_at.future?
  end
end
