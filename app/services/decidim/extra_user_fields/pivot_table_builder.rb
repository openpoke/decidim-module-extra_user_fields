# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Produces a PivotTable that cross-tabulates a participation metric
    # against two user-profile dimensions within a single participatory space.
    class PivotTableBuilder
      # @param participatory_space [Decidim::ParticipatoryProcess, Decidim::Assembly]
      # @param metric_name [String] key from InsightMetrics::REGISTRY
      # @param row_field [String] extra user field name for the Y axis
      # @param col_field [String] extra user field name for the X axis
      def initialize(participatory_space:, metric_name:, row_field:, col_field:)
        @participatory_space = participatory_space
        @metric_name = metric_name
        @row_field = row_field
        @col_field = col_field
      end

      # @return [Decidim::ExtraUserFields::PivotTable]
      def call
        metric_data = run_metric
        return empty_pivot_table if metric_data.empty?

        users = load_users(metric_data.keys)
        cells = build_cells(metric_data, users)

        row_vals = cells.keys.sort_by { |v| sort_key(v, row_field) }
        col_vals = cells.values.flat_map(&:keys).uniq.sort_by { |v| sort_key(v, col_field) }

        PivotTable.new(row_values: row_vals, col_values: col_vals, cells: cells)
      end

      private

      attr_reader :participatory_space, :metric_name, :row_field, :col_field

      def run_metric
        klass = InsightMetrics.metric_class(metric_name)
        return {} unless klass

        klass.new(participatory_space).call
      end

      def load_users(user_ids)
        Decidim::User
          .where(id: user_ids)
          .pluck(:id, :extended_data)
          .to_h
      end

      def build_cells(metric_data, users)
        cells = Hash.new { |h, k| h[k] = Hash.new(0) }

        metric_data.each do |user_id, count|
          extended_data = (users[user_id] || {}).with_indifferent_access
          row_val = extract_field(extended_data, row_field)
          col_val = extract_field(extended_data, col_field)

          cells[row_val][col_val] += count
        end

        cells
      end

      def extract_field(extended_data, field)
        extended_data[field].presence
      end

      def empty_pivot_table
        PivotTable.new(row_values: [], col_values: [], cells: {})
      end

      # Sort values using domain order when available (e.g. age_ranges, genders),
      # falling back to alphabetical. Nil (non-specified) always goes last.
      def sort_key(value, field)
        return [1, 0] if value.nil?

        ordered = ordered_values_for(field)
        if ordered
          index = ordered.index(value.to_s)
          index ? [0, index] : [0, ordered.size, value.to_s]
        else
          [0, 0, value.to_s]
        end
      end

      def ordered_values_for(field)
        @ordered_values ||= {}
        return @ordered_values[field] if @ordered_values.has_key?(field)

        @ordered_values[field] = case field.to_s
                                 when "gender" then Decidim::ExtraUserFields.genders
                                 when "age_range" then Decidim::ExtraUserFields.age_ranges
                                 end
      end
    end
  end
end
