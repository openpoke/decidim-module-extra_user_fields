# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    describe ExtraUserFieldsController do
      routes { Decidim::ExtraUserFields::Engine.routes }

      let(:organization) { create(:organization, extra_user_fields:) }
      let(:extra_user_fields) { { "enabled" => true, "underage" => { "enabled" => true, "required" => false, "limit" => 16 } } }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET retrieve_underage_limit" do
        it "returns the limit configured in the admin" do
          get :retrieve_underage_limit

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq("underage_limit" => 16)
        end

        context "when no underage limit is configured" do
          let(:extra_user_fields) { { "enabled" => true } }

          it "returns not found" do
            get :retrieve_underage_limit

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body).to eq("error" => "Underage limit not found")
          end
        end
      end
    end
  end
end
