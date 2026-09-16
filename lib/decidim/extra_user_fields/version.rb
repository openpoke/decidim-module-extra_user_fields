# frozen_string_literal: true

module Decidim
  # This holds the decidim-extra_user_fields version.
  module ExtraUserFields
    VERSION = "0.32.0"
    DECIDIM_VERSION = "~> 0.32.0"
    COMPAT_DECIDIM_VERSION = [">= 0.32", "< 0.33"].freeze

    def self.version
      VERSION
    end
  end
end
