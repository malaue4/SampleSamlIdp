# frozen_string_literal: true

class Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  class_attribute :range_attributes, default: []

  def self.range_attribute(name, type, after: "#{name}_after", before: "#{name}_before")
    attribute after, type
    attribute before, type
    self.range_attributes += [ [ name, after, before ] ]
  end

  range_attribute :created_at, :datetime, after: :created_after, before: :created_before

  def apply!(relation)
    attributes.each do |name, value|
      next if value.blank? || range_attribute?(name)

      relation.where!(name => value)
    end

    range_attributes.each do |base_name, after_name, before_name|
      after_val = public_send(after_name)
      before_val = public_send(before_name)

      next if after_val.blank? && before_val.blank?

      relation.where!(base_name => after_val..before_val)
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

  def range_attribute?(name)
    range_attributes.any? do |_base, after, before|
      name.to_s == after.to_s || name.to_s == before.to_s
    end
  end

  def attribute_type(name)
    type = self.class.type_for_attribute(name).type || :string

    case type
    when :string then :text
    else type
    end
  end
end
