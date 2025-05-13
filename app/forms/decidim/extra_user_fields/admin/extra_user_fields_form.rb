# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Boolean
        attribute :country, Boolean
        attribute :postal_code, Boolean
        attribute :date_of_birth, Boolean
        attribute :gender, Boolean
        attribute :age_range, Boolean
        attribute :phone_number, Boolean
        attribute :location, Boolean
        attribute :underage, Boolean
        attribute :underage_limit, Integer

        attribute :phone_number_pattern, String
        translatable_attribute :phone_number_placeholder, String

        attribute :select_fields, Array, default: []
        attribute :boolean_fields, Array, default: []
        attribute :text_fields, Array, default: []

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]
          self.country = model.extra_user_fields.dig("country", "enabled")
          self.postal_code = model.extra_user_fields.dig("postal_code", "enabled")
          self.date_of_birth = model.extra_user_fields.dig("date_of_birth", "enabled")
          self.gender = model.extra_user_fields.dig("gender", "enabled")
          self.age_range = model.extra_user_fields.dig("age_range", "enabled")
          self.phone_number = model.extra_user_fields.dig("phone_number", "enabled")
          self.location = model.extra_user_fields.dig("location", "enabled")
          self.underage = model.extra_user_fields.dig("underage", "enabled")
          self.underage_limit = model.extra_user_fields.fetch("underage_limit", Decidim::ExtraUserFields.underage_limit)
          self.phone_number_pattern = model.extra_user_fields.dig("phone_number", "pattern")
          self.phone_number_placeholder = model.extra_user_fields.dig("phone_number", "placeholder")
          self.select_fields = model.extra_user_fields["select_fields"] || []
          self.boolean_fields = model.extra_user_fields["boolean_fields"] || []
          self.text_fields = model.extra_user_fields["text_fields"] || []
        end

        def select_fields
          super.filter do |field|
            Decidim::ExtraUserFields.select_fields.keys.map(&:to_s).include?(field)
          end
        end

        def boolean_fields
          super.filter do |field|
            Decidim::ExtraUserFields.boolean_fields.map(&:to_s).include?(field)
          end
        end

        def text_fields
          super.filter do |field|
            Decidim::ExtraUserFields.text_fields.keys.map(&:to_s).include?(field)
          end
        end
      end
    end
  end
end
