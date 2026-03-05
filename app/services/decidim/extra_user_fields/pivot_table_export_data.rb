# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # A class with the responsibility to convert a PivotTable into an array of hashes for export.
    class PivotTableExportData
      ROW_HEADER_KEY = "Row"
      TOTAL_KEY = "Total"

      # Public: Initializes the converter.
      #
      # pivot_table - A PivotTable instance to convert.
      # row_field   - A String with the row field name.
      # col_field   - A String with the column field name.
      def initialize(pivot_table, row_field:, col_field:)
        @pivot_table = pivot_table
        @row_field_obj = InsightFields.for(row_field)
        @col_field_obj = InsightFields.for(col_field)
      end

      def rows
        data_rows + [totals_row]
      end

      private

      attr_reader :pivot_table, :row_field_obj, :col_field_obj

      def data_rows
        pivot_table.row_values.map do |row_val|
          row = { ROW_HEADER_KEY => row_label(row_val) }
          pivot_table.col_values.each do |col_val|
            row[col_label(col_val)] = pivot_table.cell(row_val, col_val)
          end
          row[TOTAL_KEY] = pivot_table.row_total(row_val)
          row
        end
      end

      def totals_row
        row = { ROW_HEADER_KEY => I18n.t("decidim.admin.extra_user_fields.insights.column_total") }
        pivot_table.col_values.each do |col_val|
          row[col_label(col_val)] = pivot_table.col_total(col_val)
        end
        row[TOTAL_KEY] = pivot_table.grand_total
        row
      end

      def row_label(value)
        return non_specified_label if value.nil?

        row_field_obj.value_label(value)
      end

      def col_label(value)
        return non_specified_label if value.nil?

        col_field_obj.value_label(value)
      end

      def non_specified_label
        I18n.t("decidim.admin.extra_user_fields.insights.non_specified")
      end
    end
  end
end
