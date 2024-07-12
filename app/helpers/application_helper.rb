module ApplicationHelper
  include Pagy::Frontend

  def link_label(link)
    case link
    in Class if link < ApplicationRecord
      link.model_name.human(count: 2)
    in ApplicationRecord
      link.model_name.human(count: 2)
    else
      link.to_s.humanize
    end
  end
end
