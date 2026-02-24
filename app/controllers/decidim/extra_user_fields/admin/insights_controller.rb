# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class InsightsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminContext
        layout :layout

        before_action :set_breadcrumbs

        def show
          enforce_permission_to :read, :insights
        end

        private

        def permission_class_chain
          [::Decidim::ExtraUserFields::Admin::Permissions] + super
        end

        def current_participatory_space
          @current_participatory_space ||=
            Decidim::ParticipatoryProcess.find_by(organization: current_organization, slug: params[:participatory_process_slug]) ||
            Decidim::Assembly.find_by!(organization: current_organization, slug: params[:assembly_slug])
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
