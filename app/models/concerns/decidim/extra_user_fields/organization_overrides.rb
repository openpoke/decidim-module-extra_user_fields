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

      def has_required_extra_user_fields?
        extra_user_fields_enabled? && any_required_field?
      end

      def required_extra_field?(field)
        field_state(field) == "required"
      end

      def extra_user_fields_complete?(user)
        extended_data = user.extended_data

        profile_field_names.each do |field|
          next unless required_extra_field?(field)

          return false if extended_data[field].blank?
        end

        check_collection_fields_complete?(extended_data, :select_fields) &&
          check_collection_fields_complete?(extended_data, :text_fields)
      end

      def at_least_one_extra_field?
        (profile_field_names + %w(underage select_fields boolean_fields text_fields)).any? do |field|
          activated_extra_field?(field)
        end
      end

      def activated_extra_field?(field)
        value = extra_user_fields[field.to_s]
        return false if value.blank?
        return true unless value.is_a?(Hash) && value.has_key?("enabled")

        field_state(field) != "disabled"
      end

      # Check if a field within a collection (select_fields, text_fields) is required.
      # Returns false for legacy Array format (arrays have no required concept).
      def collection_field_required?(collection, field)
        fields = extra_user_fields[collection.to_s]
        return false unless fields.is_a?(Hash)

        fields[field.to_s] == "required"
      end

      def age_limit
        extra_user_fields["underage_limit"].to_i
      end

      def extra_user_field_configuration(field)
        return {} unless activated_extra_field?(field)

        value = extra_user_fields[field.to_s]
        return value.except("enabled") if value.is_a?(Hash)

        value
      end

      private

      def profile_field_names
        Decidim::ExtraUserFields::PROFILE_FIELDS
      end

      def any_required_field?
        profile_field_names.any? { |field| required_extra_field?(field) } ||
          %w(select_fields text_fields).any? do |collection|
            fields = extra_user_fields[collection]
            fields.is_a?(Hash) && fields.keys.any? { |name| collection_field_required?(collection, name) }
          end
      end

      def check_collection_fields_complete?(extended_data, collection_name)
        active_fields = extra_user_fields.fetch(collection_name.to_s, {})
        return true if active_fields.blank? || !active_fields.is_a?(Hash)

        user_data = extended_data.fetch(collection_name.to_s, {})
        active_fields.each do |field_name, _|
          next unless collection_field_required?(collection_name, field_name)

          return false if user_data[field_name.to_s].blank?
        end
        true
      end

      # Returns normalized state string for a profile field.
      # Handles legacy `true` → "optional", missing/blank → "disabled".
      def field_state(field)
        value = extra_user_fields[field.to_s]
        return "disabled" if value.blank?
        return "optional" if value == true
        return value["enabled"].presence || "disabled" if value.is_a?(Hash) && value.has_key?("enabled")

        "disabled"
      end
    end
  end
end
