# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Forces signed-in users to complete mandatory extra user fields
    # before they can navigate the platform.
    module NeedsExtraUserFieldsCompleted
      extend ActiveSupport::Concern

      included do
        before_action :extra_user_fields_completed_by_user
      end

      private

      def extra_user_fields_completed_by_user
        return unless request.format.html?
        return unless current_user
        return unless current_user.tos_accepted?
        return unless current_organization.respond_to?(:force_extra_user_fields?)
        return unless current_organization.force_extra_user_fields?
        return if current_organization.extra_user_fields_complete?(current_user)
        return if permitted_extra_fields_path?

        store_location_for(
          current_user,
          stored_location_for(current_user) || request.path
        )

        flash[:warning] = t("decidim.extra_user_fields.force_extra_user_fields.redirect_message")
        redirect_to decidim.account_path
      end

      def permitted_extra_fields_path?
        return true if request.path.start_with?(decidim.download_your_data_path)

        permitted_paths = [
          decidim.account_path,
          decidim.delete_account_path,
          decidim.destroy_user_session_path,
          decidim.accept_tos_path
        ]

        permitted_paths.any? { |path| path.split("?").first == request.path }
      end
    end
  end
end
