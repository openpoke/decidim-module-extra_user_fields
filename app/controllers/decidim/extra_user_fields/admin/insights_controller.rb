# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class InsightsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminContext
        participatory_space_admin_layout
        helper InsightsHelper

        helper_method :pivot_table_presenter, :current_metric, :current_row_field, :current_col_field,
                      :available_metrics, :available_fields

        before_action :set_breadcrumbs

        def show
          enforce_permission_to :read, :insights
        end

        private

        def pivot_table_presenter
          @pivot_table_presenter ||= PivotTablePresenter.new(
            PivotTableBuilder.new(
              participatory_space: current_participatory_space,
              metric_name: current_metric,
              row_field: current_row_field,
              col_field: current_col_field
            ).call
          )
        end

        def current_metric
          @current_metric ||= detect_metric(params[:metric]) || available_metrics.first
        end

        def current_row_field
          @current_row_field ||= detect_field(params[:rows]) || available_fields.first
        end

        def current_col_field
          @current_col_field ||= detect_field(params[:cols]) || available_fields.second
        end

        def available_metrics
          @available_metrics ||= InsightMetrics.available_metrics
        end

        def available_fields
          @available_fields ||= Decidim::ExtraUserFields.insight_fields
        end

        def detect_metric(name)
          name = name.to_s
          name if InsightMetrics.valid_metric?(name)
        end

        def detect_field(name)
          name = name.to_s
          name if available_fields.include?(name)
        end

        def permission_class_chain
          [
            ::Decidim::ExtraUserFields::Admin::Permissions,
            current_participatory_space.manifest.permissions_class,
            ::Decidim::Admin::Permissions
          ]
        end

        def current_participatory_space
          @current_participatory_space ||= if params[:participatory_process_slug]
                                             Decidim::ParticipatoryProcess.find_by!(organization: current_organization, slug: params[:participatory_process_slug])
                                           else
                                             Decidim::Assembly.find_by!(organization: current_organization, slug: params[:assembly_slug])
                                           end
        end

        def set_breadcrumbs
          if params[:participatory_process_slug]
            secondary_breadcrumb_menus << :admin_participatory_process_menu
          elsif params[:assembly_slug]
            secondary_breadcrumb_menus << :admin_assembly_menu
          end
        end
      end
    end
  end
end
