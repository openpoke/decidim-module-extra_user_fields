# frozen_string_literal: true

require "spec_helper"

describe "Force extra user fields completion" do
  let(:organization) { create(:organization, extra_user_fields:) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:user) { create(:user, :confirmed, organization:, password:, extended_data:) }

  let(:extra_user_fields) do
    {
      "enabled" => true,
      "force_extra_user_fields" => true,
      "country" => { "enabled" => true },
      "gender" => { "enabled" => true },
      "date_of_birth" => { "enabled" => false },
      "postal_code" => { "enabled" => false },
      "age_range" => { "enabled" => false },
      "phone_number" => { "enabled" => false },
      "location" => { "enabled" => false }
    }
  end

  before do
    switch_to_host(organization.host)
  end

  context "when user has NOT completed extra fields" do
    let(:extended_data) { {} }

    it "redirects to account page with a warning" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")
    end

    it "allows access to the account page and highlights empty required fields" do
      login_as user, scope: :user
      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_css("form.edit_user")
      expect(page).to have_css("label[for='user_country'].is-invalid-label")
      expect(page).to have_css("label[for='user_gender'].is-invalid-label")
    end

    it "allows access to the delete account page" do
      login_as user, scope: :user
      visit decidim.delete_account_path

      expect(page).to have_current_path(decidim.delete_account_path)
    end

    it "allows access to the download your data page" do
      login_as user, scope: :user
      visit decidim.download_your_data_path

      expect(page).to have_current_path(decidim.download_your_data_path)
    end

    it "allows free navigation after completing profile" do
      login_as user, scope: :user
      visit decidim.root_path

      # Should be redirected to account page
      expect(page).to have_current_path(decidim.account_path)

      # Fill in the required fields and submit
      within "form.edit_user" do
        select "Argentina", from: :user_country
        select "Female", from: :user_gender
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      # After completing profile, user can freely navigate
      visit decidim.notifications_settings_path
      expect(page).to have_current_path(decidim.notifications_settings_path)
    end
  end

  context "when user HAS completed extra fields" do
    let(:extended_data) { { "country" => "ES", "gender" => "female" } }

    it "does not redirect and allows normal navigation" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
      expect(page).to have_no_content("Please complete your profile information before continuing.")
    end
  end

  context "when force_extra_user_fields is disabled" do
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "force_extra_user_fields" => false,
        "country" => { "enabled" => true },
        "gender" => { "enabled" => true }
      }
    end
    let(:extended_data) { {} }

    it "does not redirect" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when extra user fields module is disabled" do
    let(:extra_user_fields) do
      {
        "enabled" => false,
        "force_extra_user_fields" => true,
        "country" => { "enabled" => true }
      }
    end
    let(:extended_data) { {} }

    it "does not redirect" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when user is not logged in" do
    let(:extended_data) { {} }

    it "does not redirect" do
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end
end
