# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Provides heatmap styling for PivotTable cells using min-max normalization.
    # Color intensity reflects where a value falls between the group minimum and maximum.
    class PivotTablePresenter
      delegate :row_values, :col_values, :cell, :row_total, :col_total,
               :grand_total, :empty?, :max_value, to: :pivot_table

      def initialize(pivot_table)
        @pivot_table = pivot_table
      end

      # Colored cells use min-max among specified (non-nil) cells.
      # Gray cells (with nil row/col) use min-max among all cells.
      def cell_style(value, row, col)
        if row.nil? || col.nil?
          min, max = all_cell_range
          heatmap_color(value, min, max, gray: true)
        else
          min, max = specified_cell_range
          heatmap_color(value, min, max)
        end
      end

      def row_total_style(value)
        total_heatmap_color(value, row_total_max)
      end

      def col_total_style(value)
        total_heatmap_color(value, col_total_max)
      end

      private

      attr_reader :pivot_table

      def specified_cell_range
        @specified_cell_range ||= begin
          values = row_values.compact.flat_map do |row|
            col_values.compact.map { |col| cell(row, col) }
          end
          min_max(values)
        end
      end

      def all_cell_range
        @all_cell_range ||= min_max(pivot_table.cells.values.flat_map(&:values))
      end

      def row_total_max
        @row_total_max ||= row_values.map { |row| row_total(row) }.max || 0
      end

      def col_total_max
        @col_total_max ||= col_values.map { |col| col_total(col) }.max || 0
      end

      def min_max(values)
        non_zero = values.select(&:positive?)
        return [0, 0] if non_zero.empty?

        non_zero.minmax
      end

      def total_heatmap_color(value, max)
        return "" if value.zero? || max.zero?

        intensity = value.to_f / max
        text_color = intensity > 0.6 ? "#fff" : "#1a1a1a"
        saturation = (50 + (intensity * 15)).round
        lightness = (90 - (intensity * 40)).round
        bg = "hsl(215, #{saturation}%, #{lightness}%)"
        "background-color: #{bg}; color: #{text_color};"
      end

      # intensity = (value - min) / (max - min); when min == max, intensity is 0.
      def heatmap_color(value, min, max, gray: false)
        return "" if value.zero? || max.zero?

        range = max - min
        intensity = range.zero? ? 0.0 : (value - min).to_f / range
        text_color = if gray
                       "#1a1a1a"
                     else
                       intensity > 0.6 ? "#fff" : "#1a1a1a"
                     end

        bg = if gray
               lightness = (95 - (intensity * 35)).round
               "hsl(0, 0%, #{lightness}%)"
             else
               hue = (50 * (1 - intensity)).round
               saturation = (90 - (intensity * 12)).round
               lightness = (86 - (intensity * 36)).round
               "hsl(#{hue}, #{saturation}%, #{lightness}%)"
             end

        "background-color: #{bg}; color: #{text_color};"
      end
    end
  end
end
