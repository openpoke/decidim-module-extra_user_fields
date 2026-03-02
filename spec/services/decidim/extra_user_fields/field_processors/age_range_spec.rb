# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  module FieldProcessors
    describe AgeRange do
      describe ".call" do
        subject { described_class.call(extended_data) }

        context "when age_range is stored directly" do
          let(:extended_data) { { "age_range" => "17_to_30" } }

          it { is_expected.to eq("17_to_30") }
        end

        context "when age_range is stored and date_of_birth is also present" do
          let(:extended_data) { { "age_range" => "17_to_30", "date_of_birth" => "1950-01-01" } }

          it "prefers the stored age_range" do
            expect(subject).to eq("17_to_30")
          end
        end

        context "when age_range is blank and date_of_birth is present" do
          let(:extended_data) { { "age_range" => "", "date_of_birth" => date_of_birth } }

          context "with a birth date in the 17_to_30 range" do
            let(:date_of_birth) { 20.years.ago.to_date.to_s }

            it { is_expected.to eq("17_to_30") }
          end

          context "with a birth date in the up_to_16 range" do
            let(:date_of_birth) { 15.years.ago.to_date.to_s }

            it { is_expected.to eq("up_to_16") }
          end

          context "with a birth date in the 31_to_60 range" do
            let(:date_of_birth) { 45.years.ago.to_date.to_s }

            it { is_expected.to eq("31_to_60") }
          end

          context "with a birth date in the 61_or_more range" do
            let(:date_of_birth) { 70.years.ago.to_date.to_s }

            it { is_expected.to eq("61_or_more") }
          end
        end

        context "when only date_of_birth is present (no age_range key)" do
          let(:extended_data) { { "date_of_birth" => 25.years.ago.to_date.to_s } }

          it { is_expected.to eq("17_to_30") }
        end

        context "when neither age_range nor date_of_birth is present" do
          let(:extended_data) { {} }

          it { is_expected.to be_nil }
        end

        context "with an invalid date_of_birth" do
          let(:extended_data) { { "date_of_birth" => "not-a-date" } }

          it { is_expected.to be_nil }
        end

        context "with a nil date_of_birth" do
          let(:extended_data) { { "date_of_birth" => nil } }

          it { is_expected.to be_nil }
        end

        context "with a future date_of_birth" do
          let(:extended_data) { { "date_of_birth" => 5.years.from_now.to_date.to_s } }

          it { is_expected.to be_nil }
        end
      end

      describe "age boundary precision" do
        subject { described_class.call("date_of_birth" => birth_date.to_s) }

        context "when the user turns 17 today" do
          let(:birth_date) { 17.years.ago.to_date }

          it { is_expected.to eq("17_to_30") }
        end

        context "when the user is still 16 (birthday tomorrow)" do
          let(:birth_date) { 17.years.ago.to_date + 1.day }

          it { is_expected.to eq("up_to_16") }
        end

        context "when the user turns 31 today" do
          let(:birth_date) { 31.years.ago.to_date }

          it { is_expected.to eq("31_to_60") }
        end

        context "when the user is still 30 (birthday tomorrow)" do
          let(:birth_date) { 31.years.ago.to_date + 1.day }

          it { is_expected.to eq("17_to_30") }
        end

        context "when the user turns 61 today" do
          let(:birth_date) { 61.years.ago.to_date }

          it { is_expected.to eq("61_or_more") }
        end

        context "when the user is still 60 (birthday tomorrow)" do
          let(:birth_date) { 61.years.ago.to_date + 1.day }

          it { is_expected.to eq("31_to_60") }
        end
      end
    end
  end
end
