# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Custom helpers, scoped to the extra_user_fields engine.
    #
    module ApplicationHelper
      def gender_options_for_select
        Decidim::ExtraUserFields.genders.map do |gender|
          [gender, I18n.t(gender, scope: "decidim.extra_user_fields.genders")]
        end
      end

      def age_range_options_for_select
        Decidim::ExtraUserFields.age_ranges.map do |age_range|
          [age_range, I18n.t(age_range, scope: "decidim.extra_user_fields.age_ranges")]
        end
      end

      def phone_number_extra_user_field_pattern
        current_organization.extra_user_field_configuration(:phone_number)["pattern"]
      end

      def phone_number_extra_user_field_placeholder
        current_organization.extra_user_field_configuration(:phone_number)["placeholder"]
      end

      def custom_select_fields_options
        return {} unless Decidim::ExtraUserFields.select_fields.is_a?(Hash)

        Decidim::ExtraUserFields.select_fields.filter_map do |field, options|
          next if options.blank?
          next unless current_organization.extra_user_field_configuration(:select_fields).include?(field.to_s)

          [
            field,
            options.is_a?(Hash) ? map_options(options) : options
          ]
        end.to_h
      end

      def map_options(options)
        options.map do |option, label|
          label = I18n.t(label, default: label.split(".").last.to_s.humanize) if label.present?
          [label, option]
        end
      end

      def custom_boolean_fields
        return [] unless Decidim::ExtraUserFields.boolean_fields.is_a?(Array)

        Decidim::ExtraUserFields.boolean_fields.filter do |field|
          current_organization.extra_user_field_configuration(:boolean_fields).include?(field.to_s)
        end
      end

      def custom_text_fields
        return [] unless Decidim::ExtraUserFields.text_fields.is_a?(Hash)

        Decidim::ExtraUserFields.text_fields.filter_map do |field, mandatory|
          current_organization.extra_user_field_configuration(:text_fields).include?(field.to_s)

          [field, mandatory.present?]
        end.to_h
      end
    end
  end
end
