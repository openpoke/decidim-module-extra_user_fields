# frozen_string_literal: true

require "spec_helper"

def fill_registration_form
  fill_in :registration_user_name, with: "Nikola Tesla"
  fill_in :registration_user_email, with: "nikola.tesla@example.org"
  fill_in :registration_user_password, with: "sekritpass123"
  page.check("registration_user_newsletter")
  page.check("registration_user_tos_agreement")
end

def fill_extra_user_fields
  fill_in_datepicker :registration_user_date_of_birth_date, with: "01/01/2000"
  select "Other", from: :registration_user_gender
  select "17 to 30", from: :registration_user_age_range
  select "Argentina", from: :registration_user_country
  select "Individual", from: :registration_user_select_fields_participant_type
  check "registration_user_boolean_fields_ngo"
  fill_in :registration_registration_user_text_fields_motto, with: "I think, therefore I am."
  fill_in :registration_user_postal_code, with: "00000"
  fill_in :registration_user_phone_number, with: "0123456789"
  fill_in :registration_user_location, with: "Cahors"
end

describe "Extra user fields" do # rubocop:disable RSpec/DescribeClass
  shared_examples_for "mandatory extra user fields" do |field|
    it "displays #{field} as mandatory" do
      within "label[for='registration_user_#{field}']" do
        expect(page).to have_css("span.label-required")
      end
    end
  end

  let(:organization) { create(:organization, extra_user_fields:) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization:) }

  let(:extra_user_fields) do
    {
      "enabled" => true,
      "date_of_birth" => date_of_birth,
      "postal_code" => postal_code,
      "gender" => gender,
      "age_range" => age_range,
      "country" => country,
      "phone_number" => phone_number,
      "location" => location,
      "select_fields" => select_fields,
      "boolean_fields" => boolean_fields,
      "text_fields" => text_fields
    }
  end

  let(:date_of_birth) do
    { "enabled" => true }
  end

  let(:postal_code) do
    { "enabled" => true }
  end

  let(:country) do
    { "enabled" => true }
  end

  let(:gender) do
    { "enabled" => true }
  end

  let(:age_range) do
    { "enabled" => true }
  end

  let(:phone_number) do
    { "enabled" => true, "pattern" => phone_number_pattern, "placeholder" => nil }
  end
  let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }

  let(:location) do
    { "enabled" => true }
  end

  let(:select_fields) do
    ["participant_type"]
  end

  let(:boolean_fields) do
    ["ngo"]
  end

  let(:text_fields) do
    ["motto"]
  end

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  it "contains extra user fields" do
    within "#card__extra_user_fields" do
      expect(page).to have_content("Date of birth")
      expect(page).to have_content("Which gender do you identify with?")
      expect(page).to have_content("Country")
      expect(page).to have_content("Postal code")
      expect(page).to have_content("Phone Number")
      expect(page).to have_content("Location")
      expect(page).to have_content("How old are you?")
      expect(page).to have_content("Are you participating as an individual, or officially on behalf of an organization?")
      expect(page).to have_content("I am a member of a non-governmental organization (NGO)")
      expect(page).to have_content("What is your motto?")
    end
  end

  it "allows to create a new account" do
    fill_registration_form
    fill_extra_user_fields

    within "form.new_user" do
      find("*[type=submit]").click
    end

    expect(page).to have_content("message with a confirmation link has been sent")

    extended_data = Decidim::User.unscoped.last.extended_data
    expect(extended_data["text_fields"]["motto"]).to eq("I think, therefore I am.")
    expect(extended_data["boolean_fields"]).to eq(["ngo"])
    expect(extended_data["select_fields"]["participant_type"]).to eq("individual")
    expect(extended_data["date_of_birth"]).to eq("2000-01-01")
    expect(extended_data["gender"]).to eq("other")
    expect(extended_data["age_range"]).to eq("17_to_30")
    expect(extended_data["country"]).to eq("AR")
    expect(extended_data["postal_code"]).to eq("00000")
    expect(extended_data["phone_number"]).to eq("0123456789")
    expect(extended_data["location"]).to eq("Cahors")
  end

  context "with phone number pattern blank" do
    let(:phone_number_pattern) { nil }

    it "allows to create a new account" do
      fill_registration_form
      fill_extra_user_fields

      within "form.new_user" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("message with a confirmation link has been sent")
    end
  end

  context "with phone number pattern not compatible with number" do
    let(:phone_number_pattern) { "^(\\+34)?[0-1 ]{9,12}$" }

    it "does not allow to create a new account" do
      fill_registration_form
      fill_extra_user_fields

      within "form.new_user" do
        find("*[type=submit]").click
      end

      expect(page).to have_no_content("message with a confirmation link has been sent")
      within("label[for='registration_user_phone_number']") do
        expect(page).to have_content("There is an error in this field.")
      end
    end
  end

  it_behaves_like "mandatory extra user fields", "date_of_birth"
  it_behaves_like "mandatory extra user fields", "gender"
  it_behaves_like "mandatory extra user fields", "age_range"
  it_behaves_like "mandatory extra user fields", "country"
  it_behaves_like "mandatory extra user fields", "postal_code"
  it_behaves_like "mandatory extra user fields", "phone_number"
  it_behaves_like "mandatory extra user fields", "location"

  context "when extra_user_fields is disabled" do
    let(:organization) { create(:organization, :extra_user_fields_disabled) }

    it "does not contain extra user fields" do
      expect(page).to have_no_content("Date of birth")
      expect(page).to have_no_content("Which gender do you identify with?")
      expect(page).to have_no_content("How old are you?")
      expect(page).to have_no_content("Country")
      expect(page).to have_no_content("Postal code")
      expect(page).to have_no_content("Phone Number")
      expect(page).to have_no_content("Location")
      expect(page).to have_no_content("Which gender do you identify with?")
      expect(page).to have_no_content("Are you participating as an individual, or officially on behalf of an organization?")
      expect(page).to have_no_content("I am a member of a non-governmental organization (NGO)")
    end

    it "allows to create a new account" do
      fill_registration_form

      within "form.new_user" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("message with a confirmation link has been sent")
    end
  end
end
