# frozen_string_literal: true

require "spec_helper"

describe "Admin views insights" do
  let(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when visiting a participatory process admin" do
    before do
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    end

    it "shows the Insights menu item" do
      within ".sidebar-menu" do
        expect(page).to have_content("Insights")
      end
    end
  end

  context "when visiting the insights page" do
    before do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug
      )
    end

    it "displays the page title" do
      expect(page).to have_content("Participatory Space Insights")
    end

    it "displays the description" do
      expect(page).to have_content("Explore participant activity across profile dimensions")
    end
  end
end
