# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This module adds the FormBuilder methods for extra user fields
    module FormBuilderMethods
      def custom_country_select(name, options = {})
        label_text = options[:label].to_s
        label_text = label_for(name) if label_text.blank?
        select_html = sanitize_country_select(country_select(name))
        (label_text + select_html).html_safe
      end

      private

      # Remove non-standard attrs added by country_select that fail HTML/accessibility validation
      def sanitize_country_select(html)
        html.gsub(/\s(skip_default_ids|allow_method_names_outside_object)="[^"]*"/, "")
      end
    end
  end
end
