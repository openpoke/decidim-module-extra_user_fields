# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # A command with all the business logic to export insights pivot table data.
      class ExportInsights < Decidim::Command
        # Public: Initializes the command.
        #
        # format              - A String with the export format (CSV, JSON, Excel).
        # current_user        - The user performing the export.
        # participatory_space - The participatory space to scope the data.
        # pivot_params        - A Hash with :metric, :row_field, :col_field.
        def initialize(format, current_user, participatory_space, pivot_params)
          @format = format
          @current_user = current_user
          @participatory_space = participatory_space
          @pivot_params = pivot_params
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when the export job is enqueued.
        #
        # Returns nothing.
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
