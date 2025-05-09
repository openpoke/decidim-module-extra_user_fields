# frozen_string_literal: true

require "decidim/extra_user_fields/admin"
require "decidim/extra_user_fields/engine"
require "decidim/extra_user_fields/admin_engine"
require "decidim/extra_user_fields/form_builder_methods"

module Decidim
  # This namespace holds the logic of the `ExtraUserFields` module.
  module ExtraUserFields
    include ActiveSupport::Configurable

    config_accessor :underage_limit do
      ENV.fetch("EXTRA_USER_FIELDS_UNDERAGE_LIMIT", 18).to_i
    end

    config_accessor :underage_options do
      ENV.fetch("EXTRA_USER_FIELDS_UNDERAGE_OPTIONS", "15 16 17 18 19 20 21").split.map(&:to_i)
    end

    # These options require the I18n translations to be set in the locale files.
    # decidim.extra_user_fields.genders.female
    # decidim.extra_user_fields.genders.male
    # decidim.extra_user_fields.genders. ...
    config_accessor :genders do
      ENV.fetch("EXTRA_USER_FIELDS_GENDERS", "female male other prefer_not_to_say").split
    end

    # These options require the I18n translations to be set in the locale files.
    # decidim.extra_user_fields.age_range.up_to_16
    # decidim.extra_user_fields.age_range.17_to_30
    # decidim.extra_user_fields.age_range. ...
    config_accessor :age_ranges do
      ENV.fetch("EXTRA_USER_FIELDS_AGE_RANGES", "up_to_16 17_to_30 31_to_60 61_or_more prefer_not_to_say").split
    end

    # I extra select fields are needed, they can be added here.
    # The key is the field name and the value is a hash with the options.
    # You can (optionally) add I18n keys for the options (if not the text will be used as it is).
    # For the admin interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.admin.extra_user_fields.select_fields.field_name.label
    # decidim.extra_user_fields.admin.extra_user_fields.select_fields.field_name.description
    config_accessor :select_fields do
      {
        participant_type: {
          individual: "decidim.extra_user_fields.participant_types.individual",
          organization: "decidim.extra_user_fields.participant_types.organization"
        }
      }
    end
  end
end
