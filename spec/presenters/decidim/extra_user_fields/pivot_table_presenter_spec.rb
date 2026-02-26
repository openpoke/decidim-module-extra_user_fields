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

      it "returns colored gradient for specified cells" do
        result = presenter.cell_style(10, "female", "young")
        expect(result).to include("background-color:")
        expect(result).to include("hsl(0, 100%, 45%)")
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

        it "uses max_specified_value for colored cells, not overall max" do
          # max_specified_value = 10 (only female/young), not 10 (overall max)
          result = presenter.cell_style(10, "female", "young")
          # At full intensity: hue=0, saturation=100%, lightness=45%
          expect(result).to include("hsl(0, 100%, 45%)")
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

    describe "max value calculations" do
      context "when some rows or cols are nil" do
        let(:row_values) { ["female", nil] }
        let(:col_values) { ["young", nil] }
        let(:cells) { { "female" => { "young" => 5, nil => 99 }, nil => { "young" => 88, nil => 77 } } }

        it "normalizes colored cells against specified-only max" do
          # max_specified_value = 5, so value 5 is full intensity
          result = presenter.cell_style(5, "female", "young")
          expect(result).to include("hsl(0, 100%, 45%)")
        end

        it "normalizes gray cells against overall max" do
          # max_value = 99, so value 99 is full intensity
          result = presenter.cell_style(99, "female", nil)
          expect(result).to include("hsl(0, 0%,")
        end
      end

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
