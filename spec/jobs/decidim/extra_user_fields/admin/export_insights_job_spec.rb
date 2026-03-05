# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ExportInsightsJob do
        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
        let(:format) { "CSV" }
        let(:pivot_params) { { metric: "participants", row_field: "gender", col_field: "age_span" } }

        it "sends an export email" do
          perform_enqueued_jobs do
            described_class.perform_now(user, format, participatory_process, pivot_params)
          end
          email = last_email
          expect(email.subject).to include("insights")
        end

        context "when format is CSV" do
          it "uses the CSV exporter" do
            export_data = double(read: "", filename: "insights")
            expect(Decidim::Exporters::CSV)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, participatory_process, pivot_params)
          end
        end

        context "when format is JSON" do
          let(:format) { "JSON" }

          it "uses the JSON exporter" do
            export_data = double(read: "", filename: "insights")
            expect(Decidim::Exporters::JSON)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, participatory_process, pivot_params)
          end
        end

        context "when format is Excel" do
          let(:format) { "Excel" }

          it "uses the Excel exporter" do
            export_data = double(read: "", filename: "insights")
            expect(Decidim::Exporters::Excel)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, participatory_process, pivot_params)
          end
        end
      end
    end
  end
end
