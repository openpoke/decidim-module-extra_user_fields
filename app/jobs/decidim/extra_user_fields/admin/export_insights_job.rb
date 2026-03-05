# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExportInsightsJob < ApplicationJob
        include Decidim::PrivateDownloadHelper

        queue_as :exports

        def perform(user, format, participatory_space, pivot_params)
          metric = pivot_params[:metric]
          row_field = pivot_params[:row_field]
          col_field = pivot_params[:col_field]

          pivot_table = PivotTableBuilder.new(
            participatory_space:,
            metric_name: metric,
            row_field:,
            col_field:
          ).call

          collection = PivotTableExportData.new(pivot_table, row_field:, col_field:).rows
          export_data = Decidim::Exporters.find_exporter(format).new(collection, PivotTableRowSerializer).export

          private_export = attach_archive(export_data, "insights", user)
          ExportMailer.export(user, private_export).deliver_later
        end
      end
    end
  end
end
