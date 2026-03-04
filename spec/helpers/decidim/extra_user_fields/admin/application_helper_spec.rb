# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ApplicationHelper do
        let(:helper_class) do
          Class.new do
            include Decidim::ExtraUserFields::Admin::ApplicationHelper
          end
        end
        let(:helper) { helper_class.new }

        describe "#field_enabled?" do
          it "returns true for optional" do
            expect(helper.field_enabled?("optional")).to be true
          end

          it "returns true for required" do
            expect(helper.field_enabled?("required")).to be true
          end

          it "returns false for disabled" do
            expect(helper.field_enabled?("disabled")).to be false
          end

          it "returns false for nil" do
            expect(helper.field_enabled?(nil)).to be false
          end

          it "returns false for empty string" do
            expect(helper.field_enabled?("")).to be false
          end
        end

        describe "#field_required?" do
          it "returns true for required" do
            expect(helper.field_required?("required")).to be true
          end

          it "returns false for optional" do
            expect(helper.field_required?("optional")).to be false
          end

          it "returns false for disabled" do
            expect(helper.field_required?("disabled")).to be false
          end

          it "returns false for nil" do
            expect(helper.field_required?(nil)).to be false
          end
        end

        describe "#field_row_class" do
          it "returns disabled class for disabled" do
            expect(helper.field_row_class("disabled")).to eq("field-row--disabled")
          end

          it "returns disabled class for blank" do
            expect(helper.field_row_class("")).to eq("field-row--disabled")
          end

          it "returns disabled class for nil" do
            expect(helper.field_row_class(nil)).to eq("field-row--disabled")
          end

          it "returns required class for required" do
            expect(helper.field_row_class("required")).to eq("field-row--required")
          end

          it "returns empty string for optional" do
            expect(helper.field_row_class("optional")).to eq("")
          end
        end

        describe "#custom_select_fields" do
          let(:form) { double(object: form_object) }
          let(:form_object) { double(select_fields: { "participant_type" => "required" }) }

          it "returns hash of field_name => state" do
            result = helper.custom_select_fields(form)
            expect(result[:participant_type]).to eq("required")
          end

          context "when field is not in form object" do
            let(:form_object) { double(select_fields: {}) }

            it "defaults to disabled" do
              result = helper.custom_select_fields(form)
              expect(result[:participant_type]).to eq("disabled")
            end
          end

          context "when select_fields config is not a Hash" do
            before { allow(Decidim::ExtraUserFields).to receive(:select_fields).and_return(nil) }

            it "returns empty hash" do
              expect(helper.custom_select_fields(form)).to eq({})
            end
          end
        end

        describe "#custom_boolean_fields" do
          let(:form) { double(object: form_object) }
          let(:form_object) { double(boolean_fields: ["ngo"]) }

          it "returns hash of field_name => checked boolean" do
            result = helper.custom_boolean_fields(form)
            expect(result[:ngo]).to be true
          end

          context "when field is not checked" do
            let(:form_object) { double(boolean_fields: []) }

            it "returns false" do
              result = helper.custom_boolean_fields(form)
              expect(result[:ngo]).to be false
            end
          end

          context "when boolean_fields config is not an Array" do
            before { allow(Decidim::ExtraUserFields).to receive(:boolean_fields).and_return(nil) }

            it "returns empty hash" do
              expect(helper.custom_boolean_fields(form)).to eq({})
            end
          end
        end

        describe "#custom_text_fields" do
          let(:form) { double(object: form_object) }
          let(:form_object) { double(text_fields: { "motto" => "optional" }) }

          it "returns hash of field_name => state" do
            result = helper.custom_text_fields(form)
            expect(result[:motto]).to eq("optional")
          end

          context "when field is not in form object" do
            let(:form_object) { double(text_fields: {}) }

            it "defaults to disabled" do
              result = helper.custom_text_fields(form)
              expect(result[:motto]).to eq("disabled")
            end
          end

          context "when text_fields config is not a Hash" do
            before { allow(Decidim::ExtraUserFields).to receive(:text_fields).and_return(nil) }

            it "returns empty hash" do
              expect(helper.custom_text_fields(form)).to eq({})
            end
          end
        end
      end
    end
  end
end
