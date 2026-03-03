# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization extra user fields" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "creates a new item in submenu" do
    visit decidim_admin.officializations_path

    within ".sidebar-menu" do
      expect(page).to have_content("Manage extra user fields")
    end
  end

  context "when accessing extra user fields" do
    before do
      visit decidim_extra_user_fields.root_path
    end

    it "displays the form" do
      within ".item_show__wrapper" do
        expect(page).to have_content("Manage extra user fields")
        expect(page).to have_css("#extra_user_fields")
      end
    end

    it "allows to enable extra user fields functionality" do
      within "#extra_user_fields" do
        expect(page).to have_content("Enable extra user fields")
        expect(page).to have_content("Available extra fields for signup form")
      end
    end

    it "hides the force extra user fields checkbox when extra user fields are disabled" do
      within "#accordion-global" do
        expect(page).to have_content("Force existing users to update their profile if missing mandatory extra user fields")

        uncheck("extra_user_fields[enabled]")

        expect(page).to have_no_content("Force existing users to update their profile if missing mandatory extra user fields")

        check("extra_user_fields[enabled]")

        expect(page).to have_content("Force existing users to update their profile if missing mandatory extra user fields")
      end
    end

    it "saves the force extra user fields setting" do
      check("extra_user_fields[enabled]")

      within "#accordion-global" do
        check("extra_user_fields[force_extra_user_fields]")
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")

      visit decidim_extra_user_fields.root_path

      expect(page).to have_checked_field("extra_user_fields[force_extra_user_fields]")
    end

    context "when form is valid" do
      it "flashes a success message" do
        check("extra_user_fields[enabled]")

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end

    context "when custom select_fields" do
      it "displays the custom select fields" do
        within "#accordion-setup" do
          expect(page).to have_content("Additional custom fields")
          expect(page).to have_content("Enable participant type")
          expect(page).to have_content("This field is a list of participant types")

          check("Enable participant type field")
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end

    context "when custom boolean_fields" do
      it "displays the custom boolean fields" do
        within "#accordion-setup" do
          expect(page).to have_content("Additional custom fields")
          expect(page).to have_content("Enable NGO field")
          expect(page).to have_content("This field is a Boolean field. User will be able to check if is a NGO")

          check("Enable NGO field")
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end

    context "when custom text_fields" do
      it "displays the custom text fields" do
        within "#accordion-setup" do
          expect(page).to have_content("Additional custom fields")
          expect(page).to have_content("Enable \"My Motto\" field")
          expect(page).to have_content("This field is a String field. If checked, user can fill in a personal phrase or motto")

          check("Enable \"My Motto\" field")
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end
  end

  context "and no translations are provided" do
    let(:custom_select_fields) do
      {
        animal_type: {
          dog: "I love dogs",
          cat: "I love cats"
        }
      }
    end
    let(:custom_boolean_fields) do
      [:dog_person]
    end
    let(:custom_text_fields) do
      {
        pet_name: false
      }
    end

    before do
      allow(Decidim::ExtraUserFields).to receive(:select_fields).and_return(custom_select_fields)
      allow(Decidim::ExtraUserFields).to receive(:boolean_fields).and_return(custom_boolean_fields)
      allow(Decidim::ExtraUserFields).to receive(:text_fields).and_return(custom_text_fields)
      visit decidim_extra_user_fields.root_path
    end

    it "displays the custom select fields" do
      within "#accordion-setup" do
        expect(page).to have_content("Additional custom fields")
        expect(page).to have_content("Animal type")

        check("Animal type")
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")
    end

    it "displays the custom boolean fields" do
      within "#accordion-setup" do
        expect(page).to have_content("Additional custom fields")
        expect(page).to have_content("Dog person")

        check("Dog person")
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")
    end

    it "displays the custom text fields" do
      within "#accordion-setup" do
        expect(page).to have_content("Additional custom fields")
        expect(page).to have_content("Pet name")

        check("Pet name")
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")
    end
  end
end
