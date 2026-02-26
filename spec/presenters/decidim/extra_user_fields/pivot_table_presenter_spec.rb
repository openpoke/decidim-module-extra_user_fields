# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe PivotTablePresenter do
    subject(:presenter) { described_class.new(pivot_table) }

    let(:pivot_table) { PivotTable.new(row_values: row_values, col_values: col_values, cells: cells) }
    let(:row_values) { %w(female male) }
    let(:col_values) { %w(young old) }
    let(:cells) { { "female" => { "young" => 10, "old" => 5 }, "male" => { "young" => 3, "old" => 2 } } }

    describe "delegation" do
      it "delegates data methods to pivot_table" do
        expect(presenter.row_values).to eq(pivot_table.row_values)
        expect(presenter.col_values).to eq(pivot_table.col_values)
        expect(presenter.cell("female", "young")).to eq(10)
        expect(presenter.row_total("female")).to eq(15)
        expect(presenter.col_total("young")).to eq(13)
        expect(presenter.grand_total).to eq(20)
        expect(presenter.empty?).to be(false)
      end
    end

    describe "#cell_style" do
      it "returns empty string when value is zero" do
        expect(presenter.cell_style(0, "female", "young")).to eq("")
      end

      it "returns colored gradient for the max value cell" do
        # min=2, max=10 → value 10 is full intensity
        result = presenter.cell_style(10, "female", "young")
        expect(result).to include("background-color:")
        expect(result).to include("hsl(0, 78%, 58%)")
      end

      it "returns baseline color for the min value cell" do
        # min=2, max=10 → value 2 has intensity 0 (baseline yellow)
        result = presenter.cell_style(2, "male", "old")
        expect(result).to include("hsl(50, 90%, 86%)")
      end

      context "when all specified cells have the same value" do
        let(:cells) { { "female" => { "young" => 5, "old" => 5 }, "male" => { "young" => 5, "old" => 5 } } }

        it "shows baseline color for all cells (no hotspots)" do
          result = presenter.cell_style(5, "female", "young")
          # min=max=5, intensity=0 → baseline yellow
          expect(result).to include("hsl(50, 90%, 86%)")
        end
      end

      context "when row or col is nil" do
        let(:row_values) { ["female", nil] }
        let(:col_values) { ["young", nil] }
        let(:cells) { { "female" => { "young" => 10, nil => 5 }, nil => { "young" => 3, nil => 7 } } }

        it "returns gray gradient when row is nil" do
          result = presenter.cell_style(7, nil, nil)
          expect(result).to include("hsl(0, 0%,")
        end

        it "returns gray gradient when col is nil" do
          result = presenter.cell_style(5, "female", nil)
          expect(result).to include("hsl(0, 0%,")
        end

        it "normalizes colored cells only against specified cells" do
          # Only specified cell is female/young=10 → min=max=10, intensity=0
          result = presenter.cell_style(10, "female", "young")
          expect(result).to include("hsl(50, 90%, 86%)")
        end
      end
    end

    describe "#row_total_style" do
      it "returns empty string when value is zero" do
        expect(presenter.row_total_style(0)).to eq("")
      end

      it "returns hsl gradient for non-zero values" do
        result = presenter.row_total_style(15)
        expect(result).to include("background-color: hsl(")
      end
    end

    describe "#col_total_style" do
      it "returns empty string when value is zero" do
        expect(presenter.col_total_style(0)).to eq("")
      end

      it "returns hsl gradient for non-zero values" do
        result = presenter.col_total_style(13)
        expect(result).to include("background-color: hsl(")
      end
    end

    describe "min-max normalization" do
      context "when there are no non-nil combinations" do
        let(:row_values) { [nil] }
        let(:col_values) { [nil] }
        let(:cells) { { nil => { nil => 10 } } }

        it "returns gray style for the only cell" do
          result = presenter.cell_style(10, nil, nil)
          expect(result).to include("hsl(0, 0%,")
        end
      end

      context "when there are no cells" do
        let(:row_values) { [] }
        let(:col_values) { [] }
        let(:cells) { {} }

        it "returns empty string for row total" do
          expect(presenter.row_total_style(0)).to eq("")
        end

        it "returns empty string for col total" do
          expect(presenter.col_total_style(0)).to eq("")
        end
      end
    end
  end
end
