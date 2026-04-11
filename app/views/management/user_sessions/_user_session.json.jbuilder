json.extract! user_session, :id, :user_id, :expires_at, :created_at, :updated_at
json.url user_session_url(user_session, format: :json)
