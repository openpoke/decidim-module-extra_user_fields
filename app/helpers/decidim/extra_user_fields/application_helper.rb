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
    end
  end
end
