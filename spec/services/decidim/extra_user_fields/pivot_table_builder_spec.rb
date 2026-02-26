# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe PivotTableBuilder do
    subject { described_class.new(participatory_space: participatory_process, metric_name: "participants", row_field: "gender", col_field: "age_range") }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }

    context "when there are no participants" do
      it "returns an empty pivot table" do
        result = subject.call
        expect(result).to be_empty
      end
    end

    context "when there are participants with extended data" do
      let(:user_female_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "17_to_30" }) }
      let(:user_male_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "male", "age_range" => "17_to_30" }) }
      let(:user_female_old) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "61_or_more" }) }
      let(:user_no_data) { create(:user, :confirmed, organization:, extended_data: {}) }

      before do
        create(:proposal, :published, component: proposal_component, users: [user_female_young])
        create(:proposal, :published, component: proposal_component, users: [user_male_young])
        create(:proposal, :published, component: proposal_component, users: [user_female_old])
        create(:proposal, :published, component: proposal_component, users: [user_no_data])
      end

      it "builds a pivot table with correct dimensions" do
        result = subject.call
        expect(result.row_values).to include("female", "male", nil)
        expect(result.col_values).to include("17_to_30", "61_or_more", nil)
      end

      it "sorts gender rows by config order, nil last" do
        result = subject.call
        # config.genders: female, male, other, prefer_not_to_say
        specified = result.row_values.compact
        expect(specified).to eq(%w(female male))
        expect(result.row_values.last).to be_nil
      end

      it "sorts age_range columns by config order, nil last" do
        result = subject.call
        # config.age_ranges: up_to_16, 17_to_30, 31_to_60, 61_or_more, prefer_not_to_say
        specified = result.col_values.compact
        expect(specified).to eq(%w(17_to_30 61_or_more))
        expect(result.col_values.last).to be_nil
      end

      it "fills cells with correct counts" do
        result = subject.call
        expect(result.cell("female", "17_to_30")).to eq(1)
        expect(result.cell("male", "17_to_30")).to eq(1)
        expect(result.cell("female", "61_or_more")).to eq(1)
        expect(result.cell(nil, nil)).to eq(1)
      end

      it "calculates correct totals" do
        result = subject.call
        expect(result.grand_total).to eq(4)
        expect(result.row_total("female")).to eq(2)
        expect(result.col_total("17_to_30")).to eq(2)
      end
    end

    context "when age_range values would sort wrong alphabetically" do
      let(:user_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "17_to_30" }) }
      let(:user_old) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "61_or_more" }) }
      let(:user_teen) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "up_to_16" }) }

      before do
        create(:proposal, :published, component: proposal_component, users: [user_young])
        create(:proposal, :published, component: proposal_component, users: [user_old])
        create(:proposal, :published, component: proposal_component, users: [user_teen])
      end

      it "sorts by domain order, not alphabetically" do
        result = subject.call
        # Alphabetical would give: 17_to_30, 61_or_more, up_to_16
        # Domain order should give: up_to_16, 17_to_30, 61_or_more
        expect(result.col_values).to eq(%w(up_to_16 17_to_30 61_or_more))
      end
    end

    context "with an invalid metric name" do
      subject { described_class.new(participatory_space: participatory_process, metric_name: "invalid", row_field: "gender", col_field: "age_range") }

      it "returns an empty pivot table" do
        result = subject.call
        expect(result).to be_empty
      end
    end
  end
end
