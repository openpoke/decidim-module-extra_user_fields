# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Admin
  describe InsightsHelper do
    describe "#metric_label" do
      it "translates known metric names" do
        expect(helper.metric_label("participants")).to eq("Participants")
        expect(helper.metric_label("proposals_created")).to eq("Proposals created")
        expect(helper.metric_label("proposals_supported")).to eq("Proposals supported")
        expect(helper.metric_label("comments")).to eq("Comments")
        expect(helper.metric_label("budget_votes")).to eq("Budget votes")
      end

      it "humanizes unknown metric names" do
        expect(helper.metric_label("unknown_metric")).to eq("Unknown metric")
      end
    end

    describe "#field_label" do
      it "translates known field names" do
        expect(helper.field_label("gender")).to eq("Gender")
        expect(helper.field_label("age_range")).to eq("Age span")
        expect(helper.field_label("country")).to eq("Country")
        expect(helper.field_label("postal_code")).to eq("Postal code")
        expect(helper.field_label("location")).to eq("Location")
      end

      it "humanizes unknown field names" do
        expect(helper.field_label("unknown_field")).to eq("Unknown field")
      end
    end

    describe "#field_value_label" do
      it "returns 'Non specified' for nil values" do
        expect(helper.field_value_label("gender", nil)).to eq("Non specified")
      end

      it "translates gender values via genders namespace" do
        expect(helper.field_value_label("gender", "female")).to eq("Female")
        expect(helper.field_value_label("gender", "male")).to eq("Male")
        expect(helper.field_value_label("gender", "other")).to eq("Other")
      end

      it "translates age_range values via age_ranges namespace" do
        expect(helper.field_value_label("age_range", "17_to_30")).to eq("17 to 30")
        expect(helper.field_value_label("age_range", "61_or_more")).to eq("61 or older")
        expect(helper.field_value_label("age_range", "up_to_16")).to eq("16 or younger")
      end

      it "falls back to humanized value for other fields" do
        expect(helper.field_value_label("country", "spain")).to eq("Spain")
        expect(helper.field_value_label("location", "some_place")).to eq("Some place")
      end
    end

    describe "#cell_style" do
      let(:pivot_table) do
        Decidim::ExtraUserFields::PivotTable.new(
          row_values: ["female", "male", nil],
          col_values: ["young", nil],
          cells: {
            "female" => { "young" => 10 },
            "male" => { "young" => 5 },
            nil => { nil => 3 }
          }
        )
      end

      it "returns empty string when value is zero" do
        expect(helper.cell_style(0, pivot_table, "female", "young")).to eq("")
      end

      it "returns colored gradient for specified cells" do
        result = helper.cell_style(10, pivot_table, "female", "young")
        expect(result).to include("background-color:")
        # Max intensity produces hue=0 (red end of yellow-to-red gradient)
        expect(result).to include("hsl(0, 100%, 45%)")
      end

      it "returns gray gradient when row is nil" do
        result = helper.cell_style(3, pivot_table, nil, nil)
        expect(result).to include("hsl(0, 0%,")
      end

      it "returns gray gradient when col is nil" do
        result = helper.cell_style(5, pivot_table, "female", nil)
        expect(result).to include("hsl(0, 0%,")
      end
    end

    describe "#row_total_style" do
      let(:pivot_table) do
        Decidim::ExtraUserFields::PivotTable.new(
          row_values: %w(a b),
          col_values: %w(x y),
          cells: { "a" => { "x" => 10, "y" => 5 }, "b" => { "x" => 3, "y" => 2 } }
        )
      end

      it "returns empty string when value is zero" do
        expect(helper.row_total_style(0, pivot_table)).to eq("")
      end

      it "returns hsl gradient for non-zero values" do
        result = helper.row_total_style(15, pivot_table)
        expect(result).to include("background-color: hsl(")
      end
    end

    describe "#col_total_style" do
      let(:pivot_table) do
        Decidim::ExtraUserFields::PivotTable.new(
          row_values: %w(a b),
          col_values: %w(x y),
          cells: { "a" => { "x" => 10, "y" => 5 }, "b" => { "x" => 3, "y" => 2 } }
        )
      end

      it "returns empty string when value is zero" do
        expect(helper.col_total_style(0, pivot_table)).to eq("")
      end

      it "returns hsl gradient for non-zero values" do
        result = helper.col_total_style(13, pivot_table)
        expect(result).to include("background-color: hsl(")
      end
    end

    describe "#insight_selector_field" do
      it "renders a selector with label and select tag" do
        result = helper.insight_selector_field(:rows, %w(gender age_range), "gender", &:humanize)

        expect(result).to include('class="insights-selectors__field"')
        expect(result).to include("Rows (Y axis)")
        expect(result).to include("<select")
        expect(result).to include("Gender")
        expect(result).to include("Age range")
        expect(result).to include("onchange")
      end

      it "marks the selected option" do
        result = helper.insight_selector_field(:rows, %w(gender age_range), "age_range", &:humanize)

        expect(result).to include("selected")
      end
    end
  end
end
