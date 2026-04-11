# frozen_string_literal: true

module LazyAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :lazy_attribute_names, default: [], instance_accessor: false

    def as_json(...)
      # Force all lazy attributes to hydrate into the ActiveModel attributes
      # hash before as_json reads from it directly.
      self.class.ancestors.each do |ancestor|
        if ancestor.respond_to?(:lazy_attribute_names, true)
          ancestor.send(:lazy_attribute_names).each { |name| public_send(name) }
        end
      end
      super
    end
  end

  class_methods do
    def lazy_attribute_names
      @lazy_attribute_names ||= []
    end

    # Declares a lazy attribute that is computed on first access and stored
    # back into the ActiveModel attributes hash, so it remains visible to
    # +as_json+, +attributes+, serialization, etc.
    #
    # @param name [Symbol] the attribute name (must already be declared with +attribute+)
    # @param allow_nil [Boolean] when true, uses a sentinel so a nil result
    #   is cached and the block is not re-evaluated.
    # @yield the block that computes the value on first access
    #
    # @example
    #   attribute :id, :string
    #   lazy_attribute(:id) { status_response_element&.[]("ID") }
    #
    #   attribute :issuer
    #   lazy_attribute(:issuer, allow_nil: true) do
    #     issuer_element.present? ? NameId.parse(issuer_element) : nil
    #   end
    #
    def lazy_attribute(name, allow_nil: false, &block)
      self.lazy_attribute_names += [ name.to_sym ]

      if allow_nil
        define_method(name) do
          sentinel_ivar = :"@_lazy_#{name}_loaded"
          unless instance_variable_get(sentinel_ivar)
            instance_variable_set(sentinel_ivar, true)
            self.send(:"#{name}=", instance_exec(&block))
          end
          super()
        end
      else
        define_method(name) do
          super() || self.send(:"#{name}=", instance_exec(&block))
        end
      end
    end
  end
end
