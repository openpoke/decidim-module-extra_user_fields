# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module OrganizationOverrides
      extend ActiveSupport::Concern

      # If true display registration field in signup form
      def extra_user_fields_enabled?
        extra_user_fields["enabled"].present? && at_least_one_extra_field?
      end

      def at_least_one_extra_field?
        extra_user_fields.filter_map do |field, _value|
          next if %w(enabled underage_limit).include?(field)

          activated_extra_field?(field)
        end.any?
      end

      # Check if the given value is enabled in extra_user_fields
      def activated_extra_field?(field)
        value = extra_user_fields[field.to_s]

        if value.is_a?(Hash)
          value["enabled"]
        else
          value
        end.present?
      end

      def age_limit?
        extra_user_fields["underage_limit"].to_i
      end

      def extra_user_field_configuration(field)
        return {} unless activated_extra_field?(field)

        value = extra_user_fields[field.to_s]

        return value.except("enabled") if value.is_a?(Hash)

        value
      end
    end
  end
end
