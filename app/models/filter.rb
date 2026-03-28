# frozen_string_literal: true

class Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :created_after, :datetime
  attribute :created_before, :datetime

  # @param [ActiveRecord::Relation] relation
  def apply!(relation)
    attributes.except("created_after", "created_before").each do |name, value|
      next if value.blank?

      relation.where!(name => value)
    end
    attributes.values_at("created_after", "created_before").then do |created_after, created_before|
      next if created_after.blank? && created_before.blank?

      relation.where!(created_at: created_after..created_before)
    end
  end

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
