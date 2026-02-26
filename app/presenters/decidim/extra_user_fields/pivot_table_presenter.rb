# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Presentation logic for PivotTable heatmap visualization.
    # Wraps a PivotTable and provides styling methods for cells, row totals, and column totals.
    # Uses min-max normalization: color intensity reflects where a value falls
    # between the minimum and maximum in its group. When all values are equal,
    # cells appear at baseline intensity (no hotspots).
    class PivotTablePresenter
      delegate :row_values, :col_values, :cell, :row_total, :col_total,
               :grand_total, :empty?, :max_value, to: :pivot_table

      def initialize(pivot_table)
        @pivot_table = pivot_table
      end

      # Inline style for a data cell's heatmap coloring.
      # Colored cells use min-max among specified (non-nil) cells.
      # Gray cells use min-max among all cells.
      def cell_style(value, row, col)
        if row.nil? || col.nil?
          min, max = all_cell_range
          heatmap_color(value, min, max, gray: true)
        else
          min, max = specified_cell_range
          heatmap_color(value, min, max)
        end
      end

      # Inline style for Row Total cells (blue gradient).
      def row_total_style(value)
        total_heatmap_color(value, row_total_max)
      end

      # Inline style for Column Total cells (blue gradient).
      def col_total_style(value)
        total_heatmap_color(value, col_total_max)
      end

      private

      attr_reader :pivot_table

      # Min-max among cells where both row and col are non-nil.
      def specified_cell_range
        @specified_cell_range ||= begin
          values = row_values.compact.flat_map do |row|
            col_values.compact.map { |col| cell(row, col) }
          end
          min_max(values)
        end
      end

      # Min-max among all cells.
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

      # Blue gradient for total cells, proportional to group max.
      def total_heatmap_color(value, max)
        return "" if value.zero? || max.zero?

        intensity = value.to_f / max
        text_color = intensity > 0.6 ? "#fff" : "#1a1a1a"
        saturation = (50 + (intensity * 15)).round
        lightness = (90 - (intensity * 40)).round
        bg = "hsl(215, #{saturation}%, #{lightness}%)"
        "background-color: #{bg}; color: #{text_color};"
      end

      # Compute inline heatmap color using min-max normalization.
      # intensity = (value - min) / (max - min), so the lowest non-zero value
      # gets baseline color and the highest gets full color.
      # When min == max (all equal), intensity is 0 (baseline).
      def heatmap_color(value, min, max, gray: false)
        return "" if value.zero? || max.zero?

        range = max - min
        intensity = range.zero? ? 0.0 : (value - min).to_f / range
        text_color = gray ? "#1a1a1a" : (intensity > 0.6 ? "#fff" : "#1a1a1a")

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
