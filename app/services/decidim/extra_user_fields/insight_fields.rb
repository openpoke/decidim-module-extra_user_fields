# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Resolves insight field names to their strategy objects.
    # Convention: "gender" -> InsightFields::Gender, "age_span" -> InsightFields::AgeSpan.
    # Falls back to Base for unknown fields (reads extended_data directly).
    module InsightFields
      # Backward-compatible aliases for renamed fields.
      ALIASES = { "age_range" => "age_span" }.freeze

      def self.for(field_name)
        name = ALIASES.fetch(field_name.to_s, field_name.to_s)
        const_name = name.camelize
        return Base.new(name) unless const_defined?(const_name, false)

        const_get(const_name, false).new
      end
    end
  end
end
