# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      module InsightsHelper
        # Render a compact selector: bordered frame with "Label: [value ▾]".
        # Yields each option to the block for label generation.
        def insight_selector_field(param_name, options, selected_value, &block)
          label_key = "decidim.admin.extra_user_fields.insights.selectors.#{param_name}"

          content_tag(:div, class: "insights-selectors__field") do
            content_tag(:span, t(label_key), class: "insights-selectors__label") +
              select_tag(
                param_name,
                options_for_select(options.map { |opt| [block.call(opt), opt] }, selected_value),
                class: "insights-selectors__select",
                onchange: "this.form.submit();"
              )
          end
        end

        # Translate a metric name for display.
        def metric_label(metric_name)
          t("decidim.admin.extra_user_fields.insights.metrics.#{metric_name}",
            default: metric_name.humanize)
        end

        # Translate a field name for display.
        def field_label(field_name)
          t("decidim.admin.extra_user_fields.insights.fields.#{field_name}",
            default: field_name.humanize)
        end

        # Translate a field value for display.
        # Tries field-specific i18n keys first (e.g., genders.female), falls back to humanize.
        def field_value_label(field_name, value)
          return t("decidim.admin.extra_user_fields.insights.non_specified") if value.nil?

          key = i18n_key_for_field_value(field_name, value)
          t(key, default: value.humanize)
        end

        # Inline style for a data cell's heatmap coloring.
        # Colored cells normalize against max of specified (non-nil) cells.
        # Gray cells normalize against the overall max.
        def cell_style(value, pivot_table, row, col)
          if row.nil? || col.nil?
            heatmap_color(value, pivot_table.max_value, gray: true)
          else
            heatmap_color(value, pivot_table.max_specified_value)
          end
        end

        # Heatmap style for Row Total cells (normalized among row totals).
        def row_total_style(value, pivot_table)
          heatmap_color(value, pivot_table.max_row_total)
        end

        # Heatmap style for Column Total cells (normalized among col totals).
        def col_total_style(value, pivot_table)
          heatmap_color(value, pivot_table.max_col_total)
        end

        private

        def i18n_key_for_field_value(field_name, value)
          case field_name.to_s
          when "gender"
            "decidim.extra_user_fields.genders.#{value}"
          when "age_range"
            "decidim.extra_user_fields.age_ranges.#{value}"
          else
            "decidim.admin.extra_user_fields.insights.field_values.#{field_name}.#{value}"
          end
        end

        # Compute inline heatmap color for a cell value.
        # When gray: true, uses a neutral gray gradient (for non-specified values).
        # Otherwise uses a yellow → red gradient.
        def heatmap_color(value, max_value, gray: false)
          return "" if max_value.zero? || value.zero?

          intensity = value.to_f / max_value
          text_color = intensity > 0.65 ? "#fff" : "#1a1a1a"

          bg = if gray
                 lightness = (95 - (intensity * 35)).round
                 "hsl(0, 0%, #{lightness}%)"
               else
                 hue = (50 * (1 - intensity)).round
                 saturation = (90 + (intensity * 10)).round
                 lightness = (90 - (intensity * 45)).round
                 "hsl(#{hue}, #{saturation}%, #{lightness}%)"
               end

          "background-color: #{bg}; color: #{text_color};"
        end
      end
    end
  end
end
