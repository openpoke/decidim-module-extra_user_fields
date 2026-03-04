# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Boolean
        attribute :country, String
        attribute :postal_code, String
        attribute :date_of_birth, String
        attribute :gender, String
        attribute :age_range, String
        attribute :phone_number, String
        attribute :location, String
        attribute :underage, Boolean
        attribute :underage_limit, Integer

        attribute :phone_number_pattern, String
        translatable_attribute :phone_number_placeholder, String

        validates(*Decidim::ExtraUserFields::PROFILE_FIELDS.map(&:to_sym),
                  inclusion: { in: %w(disabled optional required) }, allow_blank: true)

        attribute :select_fields, Hash, default: {}
        attribute :boolean_fields, Array, default: []
        attribute :text_fields, Hash, default: {}

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]
          Decidim::ExtraUserFields::PROFILE_FIELDS.each do |field|
            send(:"#{field}=", normalize_field_state(model.extra_user_fields.dig(field, "enabled")))
          end
          self.underage = model.extra_user_fields.dig("underage", "enabled")
          self.underage_limit = model.extra_user_fields.fetch("underage_limit", Decidim::ExtraUserFields.underage_limit)
          self.phone_number_pattern = model.extra_user_fields.dig("phone_number", "pattern")
          self.phone_number_placeholder = model.extra_user_fields.dig("phone_number", "placeholder")
          self.select_fields = normalize_collection_fields(model.extra_user_fields["select_fields"], Decidim::ExtraUserFields.select_fields.keys)
          self.boolean_fields = normalize_boolean_fields(model.extra_user_fields["boolean_fields"])
          self.text_fields = normalize_collection_fields(model.extra_user_fields["text_fields"], Decidim::ExtraUserFields.text_fields.keys)
        end

        def select_fields
          normalize_collection_fields(super, Decidim::ExtraUserFields.select_fields.keys)
        end

        def boolean_fields
          normalize_boolean_fields(super)
        end

        def text_fields
          normalize_collection_fields(super, Decidim::ExtraUserFields.text_fields.keys)
        end

        private

        def normalize_collection_fields(value, valid_keys)
          return {} unless value.is_a?(Hash)

          valid = valid_keys.map(&:to_s)
          value.select { |k, v| valid.include?(k.to_s) && %w(optional required).include?(v) }
        end

        def normalize_boolean_fields(value)
          valid = Decidim::ExtraUserFields.boolean_fields.map(&:to_s)
          Array(value).select { |f| valid.include?(f.to_s) }
        end

        def normalize_field_state(value)
          return "optional" if value == true
          return value if %w(disabled optional required).include?(value)

          "disabled"
        end
      end
    end
  end
end
