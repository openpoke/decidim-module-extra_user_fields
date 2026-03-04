# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    class StructureNormalizer
      def normalize_all
        Decidim::Organization.find_each do |organization|
          next if organization.extra_user_fields.blank?

          normalized = normalize_structure(organization.extra_user_fields)
          organization.update_column(:extra_user_fields, normalized)
        end
      end

      private

      def normalize_structure(fields)
        {
          "enabled" => fields["enabled"].presence || false
        }.tap do |result|
          # Normalize standard profile fields
          normalize_profile_fields(fields, result)

          # Normalize phone_number (keep extra properties)
          normalize_phone_number(fields, result)

          # Normalize underage (merge underage_limit into it)
          normalize_underage(fields, result)

          # Normalize collection fields
          normalize_select_fields(fields, result)
          normalize_boolean_fields(fields, result)
          normalize_text_fields(fields, result)
        end
      end

      def normalize_profile_fields(fields, result)
        %w(country postal_code date_of_birth gender age_range location).each do |field|
          next unless fields.key?(field)

          field_value = fields[field]
          state = if field_value.is_a?(Hash) && field_value.key?("enabled")
                    field_value["enabled"]
                  else
                    field_value
                  end

          result[field] = convert_state_to_booleans(state)
        end
      end

      def normalize_phone_number(fields, result)
        return unless fields.key?("phone_number")

        phone_data = fields["phone_number"]
        if phone_data.is_a?(Hash)
          state = phone_data["enabled"]
          result["phone_number"] = convert_state_to_booleans(state).merge(
            "pattern" => phone_data["pattern"],
            "placeholder" => phone_data["placeholder"]
          ).compact
        else
          result["phone_number"] = convert_state_to_booleans(phone_data)
        end
      end

      def normalize_underage(fields, result)
        underage_data = fields["underage"]
        underage_limit = fields["underage_limit"]

        if underage_data.is_a?(Hash)
          # New format or partial migration
          enabled = underage_data["enabled"]
          result["underage"] = {
            "enabled" => enabled.present? && enabled != false,
            "required" => false,
            "limit" => underage_limit || 18
          }
        elsif underage_data.present?
          # Legacy boolean
          result["underage"] = {
            "enabled" => underage_data == true || underage_data == "true",
            "required" => false,
            "limit" => underage_limit || 18
          }
        else
          result["underage"] = {
            "enabled" => false,
            "required" => false,
            "limit" => underage_limit || 18
          }
        end
      end

      def normalize_select_fields(fields, result)
        select_data = fields["select_fields"]
        return unless select_data.present?
        return unless select_data.is_a?(Hash)

        result["select_fields"] = select_data.transform_values do |value|
          if value.is_a?(Hash) && value.key?("enabled")
            value # Already normalized
          else
            convert_state_to_booleans(value)
          end
        end
      end

      def normalize_boolean_fields(fields, result)
        boolean_data = fields["boolean_fields"]
        return unless boolean_data.present?

        if boolean_data.is_a?(Array)
          # Legacy array format - all enabled, none required
          result["boolean_fields"] = boolean_data.index_with do |_field|
            { "enabled" => true, "required" => false }
          end
        elsif boolean_data.is_a?(Hash)
          result["boolean_fields"] = boolean_data.transform_values do |value|
            if value.is_a?(Hash) && value.key?("enabled")
              value # Already normalized
            else
              convert_state_to_booleans(value)
            end
          end
        end
      end

      def normalize_text_fields(fields, result)
        text_data = fields["text_fields"]
        return unless text_data.present?
        return unless text_data.is_a?(Hash)

        result["text_fields"] = text_data.transform_values do |value|
          if value.is_a?(Hash) && value.key?("enabled")
            value # Already normalized
          else
            convert_state_to_booleans(value)
          end
        end
      end

      def convert_state_to_booleans(state)
        case state
        when "optional", true
          { "enabled" => true, "required" => false }
        when "required"
          { "enabled" => true, "required" => true }
        else # "disabled", false, nil, or unknown
          { "enabled" => false, "required" => false }
        end
      end
    end
  end
end
