class AddIpAddressAndUserAgentToUserSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :user_sessions, :ip_address, :string
    add_column :user_sessions, :user_agent, :string, limit: 512
  end
end
