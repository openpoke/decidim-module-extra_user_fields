# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ExtraUserFieldsController < ApplicationController
      def retrieve_underage_limit
        underage_limit = current_organization.extra_user_fields.dig("underage", "limit")
        if underage_limit.present?
          render json: { underage_limit: }
        else
          render json: { error: "Underage limit not found" }, status: :not_found
        end
      end
    end
  end
end
