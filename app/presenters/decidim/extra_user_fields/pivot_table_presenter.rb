# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Presentation logic for PivotTable heatmap visualization.
    # Wraps a PivotTable and provides styling methods for cells, row totals, and column totals.
    class PivotTablePresenter
      delegate :row_values, :col_values, :cell, :row_total, :col_total,
               :grand_total, :empty?, :max_value, to: :pivot_table

      def initialize(pivot_table)
        @pivot_table = pivot_table
      end

      # Inline style for a data cell's heatmap coloring.
      # Colored cells normalize against max of specified (non-nil) cells.
      # Gray cells normalize against the overall max.
      def cell_style(value, row, col)
        if row.nil? || col.nil?
          heatmap_color(value, max_value, gray: true)
        else
          heatmap_color(value, max_specified_value)
        end
      end

      # Heatmap style for Row Total cells (normalized among row totals).
      def row_total_style(value)
        heatmap_color(value, max_row_total)
      end

      # Heatmap style for Column Total cells (normalized among col totals).
      def col_total_style(value)
        heatmap_color(value, max_col_total)
      end

      private

      attr_reader :pivot_table

      # Max among cells where both row and col are non-nil.
      # Used for heatmap normalization of colored (non-gray) cells.
      def max_specified_value
        @max_specified_value ||= begin
          values = row_values.compact.flat_map do |row|
            col_values.compact.map { |col| cell(row, col) }
          end
          values.max || 0
        end
      end

      def max_row_total
        @max_row_total ||= row_values.map { |row| row_total(row) }.max || 0
      end

      def max_col_total
        @max_col_total ||= col_values.map { |col| col_total(col) }.max || 0
      end

      # Compute inline heatmap color for a cell value.
      # When gray: true, uses a neutral gray gradient (for non-specified values).
      # Otherwise uses a yellow -> red gradient.
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
