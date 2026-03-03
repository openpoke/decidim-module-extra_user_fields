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

      def force_extra_user_fields?
        extra_user_fields_enabled? && extra_user_fields["force_extra_user_fields"].present?
      end

      def extra_user_fields_complete?(user)
        extended_data = user.extended_data

        Decidim::ExtraUserFields.completable_fields.each do |field|
          next unless activated_extra_field?(field)

          return false if extended_data[field.to_s].blank?
        end

        check_collection_fields_complete?(extended_data, :select_fields, Decidim::ExtraUserFields.select_fields) &&
          check_collection_fields_complete?(extended_data, :text_fields, Decidim::ExtraUserFields.text_fields)
      end

      def at_least_one_extra_field?
        extra_user_fields.any? do |field, _value|
          next if %w(enabled underage_limit force_extra_user_fields).include?(field)

          activated_extra_field?(field)
        end
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

      private

      def check_collection_fields_complete?(extended_data, collection_name, configured_fields)
        active_fields = extra_user_fields.fetch(collection_name.to_s, [])
        return true if active_fields.blank?

        user_data = extended_data.fetch(collection_name.to_s, {})

        active_fields.each do |field_name|
          config_value = configured_fields[field_name.to_sym] || configured_fields[field_name.to_s]
          next if config_value.nil?
          next if config_value == false

          return false if user_data[field_name.to_s].blank?
        end

        true
      end
    end
  end
end
