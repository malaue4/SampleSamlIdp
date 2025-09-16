module ApplicationHelper
  include Pagy::Frontend

  def link_label(link)
    case link
    in Class if link < ApplicationRecord
      "Case 1 - " + link.model_name.human(count: 2)
    in ApplicationRecord
      "Case 2 - " + link.model_name.human(count: 2)
    else
      "Case 3 - " + link.to_s.humanize
    end
  end
end
