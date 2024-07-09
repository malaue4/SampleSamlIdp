class User < ApplicationRecord
  alias_attribute :nameid, :name_id

  has_many :user_sessions, dependent: :delete_all
  has_one :active_session, ->(user) {
    where(id: user.user_sessions.maximum(:id), expires_at: Time.current..)
  }, class_name: "UserSession"

  has_secure_password

  before_create do
    self.notes ||= { password: }
  end

  def persistent
    name_id
  end

  def active?
    expires_at.future?
  end
end
