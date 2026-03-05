# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # Command to export insights pivot table data from a participatory space.
      class ExportInsights < Decidim::Command
        # format - a string representing the export format (CSV, JSON, Excel)
        # current_user - the user performing the action
        # participatory_space - the scoped participatory space
        # pivot_params - hash with :metric, :row_field, :col_field
        def initialize(format, current_user, participatory_space, pivot_params)
          @format = format
          @current_user = current_user
          @participatory_space = participatory_space
          @pivot_params = pivot_params
        end

        # Enqueues an async export job.
        #
        # Broadcasts :ok if successful.
        def call
          Decidim.traceability.perform_action!(
            :export_insights,
            participatory_space,
            current_user
          ) do
            ExportInsightsJob.perform_later(current_user, format, participatory_space, pivot_params)
          end

          broadcast(:ok)
        end

        private

        attr_reader :format, :current_user, :participatory_space, :pivot_params
      end
    end
  end
end
