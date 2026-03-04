# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ExtraUserFieldsForm do
        subject do
          described_class.from_params(
            attributes
          ).with_context(
            context
          )
        end

        let(:organization) { create(:organization) }
        let(:extra_user_fields) { true }

        let(:attributes) do
          {
            extra_user_fields:
          }
        end

        let(:context) do
          {
            current_organization: organization
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        describe "validation" do
          context "when a profile field has an invalid state" do
            let(:attributes) { { country: "foobar" } }

            it { is_expected.not_to be_valid }
          end

          context "when a profile field is required" do
            let(:attributes) { { country: "required" } }

            it { is_expected.to be_valid }
          end

          context "when a profile field is optional" do
            let(:attributes) { { country: "optional" } }

            it { is_expected.to be_valid }
          end

          context "when a profile field is disabled" do
            let(:attributes) { { country: "disabled" } }

            it { is_expected.to be_valid }
          end
        end

        describe "#map_model" do
          let(:org_extra_user_fields) do
            {
              "enabled" => true,
              "country" => { "enabled" => "required" },
              "postal_code" => { "enabled" => "optional" },
              "gender" => { "enabled" => "disabled" },
              "date_of_birth" => { "enabled" => "disabled" },
              "age_range" => { "enabled" => "disabled" },
              "phone_number" => { "enabled" => "optional", "pattern" => "^\\+33", "placeholder" => { "en" => "+33..." } },
              "location" => { "enabled" => "disabled" },
              "underage" => { "enabled" => true },
              "underage_limit" => 16,
              "select_fields" => { "participant_type" => "required" },
              "boolean_fields" => ["ngo"],
              "text_fields" => { "motto" => "optional" }
            }
          end
          let(:model) { build(:organization, extra_user_fields: org_extra_user_fields) }

          before { subject.map_model(model) }

          it "loads standard field states" do
            expect(subject.country).to eq("required")
            expect(subject.postal_code).to eq("optional")
            expect(subject.gender).to eq("disabled")
          end

          it "loads phone_number config" do
            expect(subject.phone_number).to eq("optional")
            expect(subject.phone_number_pattern).to eq("^\\+33")
            expect(subject.phone_number_placeholder).to eq({ "en" => "+33..." })
          end

          it "loads underage config" do
            expect(subject.underage).to be true
            expect(subject.underage_limit).to eq(16)
          end

          it "loads collection fields" do
            select_result = subject.select_fields
            expect(select_result.keys.map(&:to_s)).to include("participant_type")
            expect(select_result.values).to include("required")
            expect(subject.boolean_fields).to eq(["ngo"])
            text_result = subject.text_fields
            expect(text_result.keys.map(&:to_s)).to include("motto")
            expect(text_result.values).to include("optional")
          end

          context "with nil/missing standard field" do
            let(:org_extra_user_fields) { { "enabled" => true } }

            it "normalizes to disabled" do
              expect(subject.country).to eq("disabled")
              expect(subject.gender).to eq("disabled")
            end
          end

          context "with missing underage_limit" do
            let(:org_extra_user_fields) { { "enabled" => true } }

            it "falls back to default" do
              expect(subject.underage_limit).to eq(Decidim::ExtraUserFields.underage_limit)
            end
          end
        end

        describe "#select_fields" do
          context "with Hash input containing valid keys" do
            let(:attributes) { { select_fields: { "participant_type" => "required", "bogus" => "optional" } } }

            it "filters invalid keys and keeps valid ones" do
              result = subject.select_fields
              expect(result.values).to eq(["required"])
              expect(result.keys.map(&:to_s)).to eq(["participant_type"])
            end
          end

          context "with Hash input containing invalid state values" do
            let(:attributes) { { select_fields: { "participant_type" => "foobar" } } }

            it "strips entries with invalid states" do
              expect(subject.select_fields).to eq({})
            end
          end

          context "with nil input" do
            let(:attributes) { { select_fields: nil } }

            it "returns empty hash" do
              expect(subject.select_fields).to eq({})
            end
          end
        end

        describe "#boolean_fields" do
          context "with valid field names" do
            let(:attributes) { { boolean_fields: ["ngo"] } }

            it "keeps valid entries" do
              expect(subject.boolean_fields).to eq(["ngo"])
            end
          end

          context "with invalid field names" do
            let(:attributes) { { boolean_fields: %w(ngo bogus) } }

            it "filters invalid entries" do
              expect(subject.boolean_fields).to eq(["ngo"])
            end
          end

          context "with nil input" do
            let(:attributes) { { boolean_fields: nil } }

            it "returns empty array" do
              expect(subject.boolean_fields).to eq([])
            end
          end
        end

        describe "#text_fields" do
          context "with Hash input containing valid keys" do
            let(:attributes) { { text_fields: { "motto" => "required", "bogus" => "optional" } } }

            it "filters invalid keys and keeps valid ones" do
              result = subject.text_fields
              expect(result.values).to eq(["required"])
              expect(result.keys.map(&:to_s)).to eq(["motto"])
            end
          end

          context "with nil input" do
            let(:attributes) { { text_fields: nil } }

            it "returns empty hash" do
              expect(subject.text_fields).to eq({})
            end
          end
        end
      end
    end
  end
end
