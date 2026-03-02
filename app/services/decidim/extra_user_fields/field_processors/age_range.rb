# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module FieldProcessors
      # Derives age_range from date_of_birth when age_range is not stored directly.
      # Falls back to the stored age_range value if present.
      #
      # Range names are parsed dynamically from Decidim::ExtraUserFields.age_ranges:
      #   "up_to_N"   → ..N
      #   "N_to_M"    → N..M
      #   "N_or_more" → N..
      class AgeRange
        RANGE_PATTERNS = {
          /\Aup_to_(?<max>\d+)\z/ => ->(m) { ..m[:max].to_i },
          /\A(?<min>\d+)_to_(?<max>\d+)\z/ => ->(m) { m[:min].to_i..m[:max].to_i },
          /\A(?<min>\d+)_or_more\z/ => ->(m) { m[:min].to_i.. }
        }.freeze

        def self.call(extended_data)
          extended_data["age_range"].presence || from_birth_date(extended_data["date_of_birth"])
        end

        def self.from_birth_date(value)
          return if value.blank?

          compute_age(value)&.then { |age| match_range(age) }
        end

        def self.compute_age(date_string)
          birth = Date.parse(date_string.to_s)
          today = Date.current
          age = today.year - birth.year - (([today.month, today.day] <=> [birth.month, birth.day]) >= 0 ? 0 : 1)
          age if age >= 0
        rescue Date::Error
          nil
        end

        def self.match_range(age)
          Decidim::ExtraUserFields.age_ranges.find { |name| parse_range(name)&.cover?(age) }
        end

        def self.parse_range(name)
          RANGE_PATTERNS.each do |pattern, builder|
            match = name.match(pattern)
            return builder.call(match) if match
          end
          nil
        end

        private_class_method :from_birth_date, :compute_age, :match_range, :parse_range
      end
    end
  end
end
