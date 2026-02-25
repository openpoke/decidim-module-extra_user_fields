# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe PivotTableBuilder do
    subject do
      described_class.new(
        participatory_space: participatory_process,
        metric_name: "participants",
        row_field: "gender",
        col_field: "age_range"
      )
    end

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
      let(:user_female_young) do
        create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "17_to_30" })
      end
      let(:user_male_young) do
        create(:user, :confirmed, organization:, extended_data: { "gender" => "male", "age_range" => "17_to_30" })
      end
      let(:user_female_old) do
        create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "61_or_more" })
      end
      let(:user_no_data) do
        create(:user, :confirmed, organization:, extended_data: {})
      end

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

    context "with an invalid metric name" do
      subject do
        described_class.new(
          participatory_space: participatory_process,
          metric_name: "invalid",
          row_field: "gender",
          col_field: "age_range"
        )
      end

      it "returns an empty pivot table" do
        result = subject.call
        expect(result).to be_empty
      end
    end
  end
end
