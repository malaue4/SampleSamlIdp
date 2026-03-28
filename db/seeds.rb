require "open-uri"

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

generator = Rubystats::NormalDistribution.new(12, 3)

User.delete_all
30.times do |i|
  name = Faker::Name.unique.name
  username, password = if i == 0
                         %w[admin 123]
  else
    [
      Faker::Internet.unique.username(specifier: name),
      Faker::Internet.password,
    ]
  end
  user = User.create!(
    name_id: SecureRandom.uuid,
    username:,
    password:,
    name:,
    email: Faker::Internet.unique.email(name:),
    phone: Faker::PhoneNumber.unique.cell_phone,
    notes: {
      password:,
      job: Faker::Job.title,
      company: Faker::Company.name,
      address: Faker::Address.full_address,
      country: Faker::Address.country,
    }
  )
  avatar_url = Faker::Avatar.image(slug: username, size: "300x300", format: "png", set: "any", bgset: "any")
  avatar = URI.open(avatar_url)
  user.avatar.attach(io: avatar, filename: "avatar.png", content_type: "image/png")
  30.times do
    created_at_date = Faker::Date.between(from: 1.month.ago, to: Date.today)
    session_length = rand(15..120).minutes
    time_of_day = [generator.rng, 0, 23.99].sort[1].hours
    created_at = created_at_date + time_of_day
    user.user_sessions.create!(
      created_at: created_at,
      expires_at: created_at + session_length,
    )
  end
end
