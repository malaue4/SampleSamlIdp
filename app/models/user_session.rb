class UserSession < ApplicationRecord
  belongs_to :user

  before_create { self.expires_at ||= 15.minutes.from_now }
end
