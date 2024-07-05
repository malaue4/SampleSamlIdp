# frozen_string_literal: true

class Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :email
  attribute :phone
  attribute :created_after, :datetime
  attribute :created_before, :datetime
end
