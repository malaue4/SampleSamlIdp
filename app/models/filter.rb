# frozen_string_literal: true

class Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :created_after, :datetime
  attribute :created_before, :datetime

  def fields
    attribute_names.index_with do |name|
      {
        type: "#{attribute_type(name)}_field"
      }
    end
  end

  private

  def attribute_type(name)
    type = self.class.type_for_attribute(name).type || :string

    case type
    when :string then :text
    else type
    end
  end
end
