# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      module InsightsHelper
        # Renders a labeled <select> that auto-submits on change.
        # Yields each option to the block for label generation.
        def insight_selector_field(param_name, options, selected_value, &block)
          label_text = t("decidim.admin.extra_user_fields.insights.selectors.#{param_name}")

          content_tag(:div, class: "insights-selectors__field") do
            label_tag(param_name, label_text, class: "insights-selectors__label") +
              select_tag(
                param_name,
                options_for_select(options.map { |opt| [block.call(opt), opt] }, selected_value),
                class: "insights-selectors__select",
                onchange: "this.form.requestSubmit();"
              )
          end
        end

        def metric_label(metric_name)
          t("decidim.admin.extra_user_fields.insights.metrics.#{metric_name}",
            default: metric_name.humanize)
        end

        def field_label(field_name)
          t("decidim.admin.extra_user_fields.insights.fields.#{field_name}",
            default: field_name.humanize)
        end

        def field_value_label(field_name, value)
          return t("decidim.admin.extra_user_fields.insights.non_specified") if value.nil?

          InsightFields.for(field_name).value_label(value)
        end

        def insights_export_dropdown
          export_path = "#{request.path}/export"
          export_name = t("decidim.admin.extra_user_fields.insights.export_name")

          export_dropdown(dropdown_id: "insights-export-dropdown") do |fmt|
            label = t("decidim.admin.exports.export_as", name: export_name, export_format: fmt)
            url = "#{export_path}?#{{ export_format: fmt, metric: current_metric,
                                      rows: current_row_field, cols: current_col_field }.to_query}"
            [label, url, :post]
          end
        end
      end
    end
  end
end
