# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationController do
    controller do
      def index
        render plain: "OK"
      end
    end

    let(:organization) { create(:organization, extra_user_fields:) }
    let(:user) { create(:user, :confirmed, organization:, extended_data: {}) }
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "force_extra_user_fields" => true,
        "country" => { "enabled" => true }
      }
    end

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    context "when request format is JSON" do
      it "does not redirect" do
        get :index, format: :json

        expect(response).not_to be_redirect
      end
    end
  end
end
