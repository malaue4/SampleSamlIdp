class User < ApplicationRecord
  alias_attribute :nameid, :name_id

  has_many :user_sessions, dependent: :delete_all
end
