# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This module adds the FormBuilder methods for extra user fields
    module FormBuilderMethods
      def custom_country_select(name, options = {})
        label_text = options[:label].presence || label_for(name)
        html = +""
        html << (label_text + required_for_attribute(name)) if options.fetch(:label, true)
        html << sanitize_country_select(country_select(name))
        html.html_safe
      end

      private

      # Remove non-standard attrs added by country_select that fail HTML/accessibility validation
      def sanitize_country_select(html)
        html.gsub(/\s(skip_default_ids|allow_method_names_outside_object)="[^"]*"/, "")
      end
    end
  end
end
