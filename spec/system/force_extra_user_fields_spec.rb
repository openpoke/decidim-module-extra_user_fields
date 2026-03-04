# frozen_string_literal: true

require "spec_helper"

describe "Force extra user fields completion" do
  let(:organization) { create(:organization, extra_user_fields:) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:user) { create(:user, :confirmed, organization:, password:, extended_data:) }

  let(:extra_user_fields) do
    {
      "enabled" => true,
      "country" => { "enabled" => "required" },
      "gender" => { "enabled" => "required" },
      "date_of_birth" => { "enabled" => "disabled" },
      "postal_code" => { "enabled" => "disabled" },
      "age_range" => { "enabled" => "disabled" },
      "phone_number" => { "enabled" => "disabled" },
      "location" => { "enabled" => "disabled" }
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
      expect(page).to have_content("Country")
      expect(page).to have_content("Which gender do you identify with?")
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

      # Required fields should be highlighted as invalid
      expect(page).to have_content("Country")
      expect(page).to have_content("Which gender do you identify with?")
      expect(page).to have_css("label[for='user_country'].is-invalid-label")
      expect(page).to have_css("label[for='user_gender'].is-invalid-label")

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

  context "when all fields are optional (none required)" do
    let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => "optional" }, "gender" => { "enabled" => "optional" } } }
    let(:extended_data) { {} }

    it "does not redirect" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when extra user fields module is disabled" do
    let(:extra_user_fields) { { "enabled" => false, "country" => { "enabled" => "required" } } }
    let(:extended_data) { {} }

    it "does not redirect" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when user has not accepted ToS and has incomplete extra fields" do
    let(:extended_data) { {} }
    let(:user) { create(:user, :confirmed, :tos_not_accepted, organization:, password:, extended_data:) }

    it "redirects to ToS page first, then to account page after accepting ToS" do
      login_as user, scope: :user
      visit decidim.root_path

      tos_page = Decidim::StaticPage.find_by(slug: "terms-of-service", organization:)

      # Should be redirected to the ToS page, not to account
      expect(page).to have_current_path(decidim.page_path(tos_page))
      expect(page).to have_content("Review updates to our terms of service")

      # Accept ToS
      click_on "I agree with these terms"

      # After accepting ToS, should be redirected to account for extra fields
      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")
    end
  end

  context "when a required custom select field is empty" do
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => "disabled" },
        "gender" => { "enabled" => "disabled" },
        "date_of_birth" => { "enabled" => "disabled" },
        "postal_code" => { "enabled" => "disabled" },
        "age_range" => { "enabled" => "disabled" },
        "phone_number" => { "enabled" => "disabled" },
        "location" => { "enabled" => "disabled" },
        "select_fields" => { "participant_type" => "required" }
      }
    end
    let(:extended_data) { {} }

    it "redirects to account page and highlights the field" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")
      expect(page).to have_css("label[for='user_select_fields_participant_type'].is-invalid-label")
    end
  end

  context "when a required custom text field is empty" do
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => "disabled" },
        "gender" => { "enabled" => "disabled" },
        "date_of_birth" => { "enabled" => "disabled" },
        "postal_code" => { "enabled" => "disabled" },
        "age_range" => { "enabled" => "disabled" },
        "phone_number" => { "enabled" => "disabled" },
        "location" => { "enabled" => "disabled" },
        "text_fields" => { "motto" => "required" }
      }
    end
    let(:extended_data) { {} }

    it "redirects to account page and highlights the field" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")
      expect(page).to have_css("label[for='user_text_fields_motto'].is-invalid-label")
    end
  end

  context "when completing a required collection field" do
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => "disabled" },
        "gender" => { "enabled" => "disabled" },
        "date_of_birth" => { "enabled" => "disabled" },
        "postal_code" => { "enabled" => "disabled" },
        "age_range" => { "enabled" => "disabled" },
        "phone_number" => { "enabled" => "disabled" },
        "location" => { "enabled" => "disabled" },
        "select_fields" => { "participant_type" => "required" }
      }
    end
    let(:extended_data) { {} }

    it "allows free navigation after filling the field" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)

      within "form.edit_user" do
        select "Individual", from: "user_select_fields_participant_type"
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      visit decidim.notifications_settings_path
      expect(page).to have_current_path(decidim.notifications_settings_path)
    end
  end

  context "when account page is refreshed with incomplete fields" do
    let(:extended_data) { {} }

    it "stays on account page without redirect loop" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")

      # Refresh the account page — must stay without redirect loop
      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Country")
    end
  end

  context "when using a non-default locale" do
    let(:extended_data) { {} }

    it "does not cause a redirect loop on account page" do
      login_as user, scope: :user
      visit "#{decidim.root_path}?locale=fr"

      # Should end up on account page regardless of locale
      expect(page).to have_current_path(/account/)

      # Refresh with locale param — must stay on account
      visit "#{decidim.account_path}?locale=fr"

      expect(page).to have_current_path(/account/)
      expect(page).to have_no_content("redirected you too many times")
    end
  end

  context "when ToS is accepted then extra fields redirect kicks in" do
    let(:extended_data) { {} }
    let(:user) { create(:user, :confirmed, :tos_not_accepted, organization:, password:, extended_data:) }

    it "flows ToS -> account without loop" do
      login_as user, scope: :user
      visit decidim.root_path

      tos_page = Decidim::StaticPage.find_by(slug: "terms-of-service", organization:)
      expect(page).to have_current_path(decidim.page_path(tos_page))

      click_on "I agree with these terms"

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")

      # Refresh — should NOT redirect back to ToS or loop
      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Country")
    end
  end

  context "when only custom collection fields are required" do
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => "disabled" },
        "gender" => { "enabled" => "disabled" },
        "date_of_birth" => { "enabled" => "disabled" },
        "postal_code" => { "enabled" => "disabled" },
        "age_range" => { "enabled" => "disabled" },
        "phone_number" => { "enabled" => "disabled" },
        "location" => { "enabled" => "disabled" },
        "select_fields" => { "participant_type" => "required" }
      }
    end
    let(:extended_data) { {} }

    it "opens account page stably without redirect loop" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")

      # Refresh — must stay on account
      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
    end
  end

  context "when user completes fields and navigates away" do
    let(:extended_data) { {} }

    it "does not redirect back to account after completion" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)

      within "form.edit_user" do
        select "Argentina", from: :user_country
        select "Female", from: :user_gender
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      # Navigate to home
      visit decidim.root_path
      expect(page).to have_current_path(decidim.root_path)

      # Refresh home — no redirect back to account
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
