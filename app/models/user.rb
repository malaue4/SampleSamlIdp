class User < ApplicationRecord
  has_many :user_sessions, dependent: :delete_all
  has_one :active_session, ->(user) {
    where(id: user.user_sessions.maximum(:id), expires_at: Time.current..)
  }, class_name: "UserSession"

  store_accessor :notes, *[
    :password,
    :job,
    :company,
    :country,
    :address
  ], prefix: true

  validates :name_id, presence: true

  has_one_attached :avatar
  validates :avatar, content_type: { with: %w[image/jpeg image/png image/gif], message: "must be a valid image" }

  has_secure_password

  before_create do
    self.password ||= Faker::Internet.password(min_length: 12, max_length: 24)
    self.notes_password ||= password
  end

  before_validation on: :create do
    self.name_id ||= SecureRandom.uuid
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
