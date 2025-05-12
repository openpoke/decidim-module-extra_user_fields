# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe UpdateExtraUserFields do
        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        let(:postal_code) { true }
        let(:extra_user_fields_enabled) { true }
        let(:country) { true }
        let(:gender) { true }
        let(:age_range) { true }
        let(:date_of_birth) { true }
        let(:phone_number) { true }
        let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }
        let(:phone_number_placeholder) { "+34999888777" }
        let(:location) { true }
        let(:underage) { true }
        let(:underage_limit) { 18 }

        let(:form_params) do
          {
            "postal_code" => postal_code,
            "enabled" => extra_user_fields_enabled,
            "country" => country,
            "gender" => gender,
            "age_range" => age_range,
            "date_of_birth" => date_of_birth,
            "phone_number" => phone_number,
            "phone_number_pattern" => phone_number_pattern,
            "phone_number_placeholder" => phone_number_placeholder,
            "location" => location,
            "underage" => underage,
            "underage_limit" => underage_limit,
            "select_fields" => %w(participant_type non_existing_field),
            "boolean_fields" => %w(ngo non_existing_field)
          }
        end
        let(:form) do
          ExtraUserFieldsForm.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "call" do
          context "when the form is not valid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't update the registration fields" do
              expect do
                command.call
                organization.reload
              end.not_to change(organization, :extra_user_fields)
            end
          end

          context "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the organization registration fields" do
              command.call
              organization.reload

              extra_user_fields = organization.extra_user_fields
              expect(extra_user_fields).to include("enabled" => true)
              expect(extra_user_fields).to include("country" => { "enabled" => true })
              expect(extra_user_fields).to include("date_of_birth" => { "enabled" => true })
              expect(extra_user_fields).to include("postal_code" => { "enabled" => true })
              expect(extra_user_fields).to include("gender" => { "enabled" => true })
              expect(extra_user_fields).to include("age_range" => { "enabled" => true })
              expect(extra_user_fields).to include("country" => { "enabled" => true })
              expect(extra_user_fields).to include("phone_number" => { "enabled" => true, "pattern" => phone_number_pattern, "placeholder" => phone_number_placeholder })
              expect(extra_user_fields).to include("location" => { "enabled" => true })
              expect(extra_user_fields).to include("underage" => { "enabled" => true })
              expect(extra_user_fields).to include("underage_limit" => 18)
              expect(extra_user_fields).to include("select_fields" => ["participant_type"])
              expect(extra_user_fields).to include("boolean_fields" => ["ngo"])
            end
          end
        end
      end
    end
  end
end
