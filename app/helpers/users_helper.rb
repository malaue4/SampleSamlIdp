module UsersHelper
  def user_avatar(user, size: 32, css_class: "")
    if user.avatar.attached?
      variant = case size
                when 0..100 then user.avatar_thumb
                else user.avatar_medium
                end
      image_tag variant,
                class: "rounded-circle #{css_class}",
                style: "width: #{size}px; height: #{size}px; object-fit: cover;"
    else
      initial = if user.respond_to?(:name) && user.name.present?
                  user.name.first
                elsif user.respond_to?(:username) && user.username.present?
                  user.username.first.upcase
                else
                  user.id.to_s.first
                end

      font_size = size / 2.5
      tag.div initial,
              class: "bg-primary text-white rounded-circle d-flex align-items-center justify-content-center #{css_class}",
              style: "width: #{size}px; height: #{size}px; font-size: #{font_size}px;"
    end
  end
end
