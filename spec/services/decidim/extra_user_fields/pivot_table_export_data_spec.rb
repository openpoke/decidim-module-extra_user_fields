# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    describe PivotTableExportData do
      subject { described_class.new(pivot_table, row_field: "gender", col_field: "age_span") }

      let(:pivot_table) do
        PivotTable.new(
          row_values: %w(female male),
          col_values: %w(21_to_30 31_to_40),
          cells: {
            "female" => { "21_to_30" => 3, "31_to_40" => 1 },
            "male" => { "21_to_30" => 2, "31_to_40" => 5 }
          }
        )
      end

      describe "#rows" do
        it "returns an array of hashes with correct size" do
          expect(subject.rows.size).to eq(3) # 2 data rows + 1 totals row
        end

        it "includes row labels" do
          row_labels = subject.rows.map { |r| r["Row"] }
          expect(row_labels).to eq(["Female", "Male", "Column Total"])
        end

        it "includes column values with translated headers" do
          first_row = subject.rows.first
          expect(first_row["21 to 30"]).to eq(3)
          expect(first_row["31 to 40"]).to eq(1)
          expect(first_row["Total"]).to eq(4)
        end

        it "includes correct totals row" do
          totals = subject.rows.last
          expect(totals["21 to 30"]).to eq(5)
          expect(totals["31 to 40"]).to eq(6)
          expect(totals["Total"]).to eq(11)
        end
      end

      context "with nil values (not specified)" do
        let(:pivot_table) do
          PivotTable.new(
            row_values: ["female", nil],
            col_values: ["21_to_30"],
            cells: {
              "female" => { "21_to_30" => 2 },
              nil => { "21_to_30" => 1 }
            }
          )
        end

        it "labels nil values as not specified" do
          row_labels = subject.rows.map { |r| r["Row"] }
          expect(row_labels).to include("Not specified / Prefer not to say")
        end
      end
    end
  end
end
