# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        def extra_user_fields_export_users_dropdown
          content_tag(:ul, class: "vertical menu add-components") do
            Decidim::ExtraUserFields::AdminEngine::DEFAULT_EXPORT_FORMATS.map do |format|
              content_tag(:li, class: "exports--format--#{format.downcase} export--users") do
                link_to(
                  t("decidim.admin.exports.export_as", name: t("decidim.extra_user_fields.admin.exports.users"), export_format: format.upcase),
                  AdminEngine.routes.url_helpers.extra_user_fields_export_users_path(format:)
                )
              end
            end.join.html_safe
          end
        end

        def custom_select_fields(form)
          return {} unless Decidim::ExtraUserFields.select_fields.is_a?(Hash)

          Decidim::ExtraUserFields.select_fields.keys.index_with do |field|
            form.object.select_fields.include?(field.to_s)
          end
        end

        def custom_boolean_fields(form)
          return {} unless Decidim::ExtraUserFields.boolean_fields.is_a?(Array)

          Decidim::ExtraUserFields.boolean_fields.index_with do |field|
            form.object.boolean_fields.include?(field.to_s)
          end
        end

        def custom_text_fields(form)
          return {} unless Decidim::ExtraUserFields.text_fields.is_a?(Array)

          Decidim::ExtraUserFields.text_fields.index_with do |field|
            form.object.text_fields.include?(field.to_s)
          end
        end
      end
    end
  end
end
