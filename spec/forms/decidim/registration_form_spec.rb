# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject { form }

    let(:form) do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization, extra_user_fields:) }
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => true },
        "postal_code" => { "enabled" => true },
        "date_of_birth" => { "enabled" => true },
        "gender" => { "enabled" => true },
        "age_range" => { "enabled" => true },
        "phone_number" => { "enabled" => true, "pattern" => phone_number_pattern, "placeholder" => nil },
        "location" => { "enabled" => true }
      }
    end
    let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }
    let(:name) { "User" }
    let(:email) { "user@example.org" }
    let(:password) { "S4CGQ9AM4ttJdPKS" }
    let(:tos_agreement) { "1" }
    let(:newsletter) { "1" }
    let(:country) { "Argentina" }
    let(:date_of_birth) { "01/01/2000" }
    let(:gender) { "other" }
    let(:age_range) { "17_to_30" }
    let(:location) { "Paris" }
    let(:phone_number) { "0123456789" }
    let(:postal_code) { "75001" }

    let(:attributes) do
      {
        name:,
        email:,
        password:,
        tos_agreement:,
        newsletter:,
        country:,
        postal_code:,
        date_of_birth:,
        gender:,
        age_range:,
        phone_number:,
        location:
      }
    end

    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the email is a disposable account" do
      let(:email) { "user@mailbox92.biz" }

      it { is_expected.not_to be_valid }
    end

    context "when the name is not present" do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end

    context "with invalid phone number format" do
      let(:phone_number_pattern) { "^(\\+34)?[0-1 ]{9,12}$" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when the email is not present" do
      let(:email) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when the email already exists" do
      context "and a user has the email" do
        let!(:user) { create(:user, organization:, email:) }

        it { is_expected.not_to be_valid }

        context "and is pending to accept the invitation" do
          let!(:user) { create(:user, organization:, email:, invitation_token: "foo", invitation_accepted_at: nil) }

          it { is_expected.not_to be_valid }
        end
      end

      context "and a user_group has the email" do
        let!(:user_group) { create(:user_group, organization:, email:) }

        it { is_expected.not_to be_valid }
      end
    end

    context "when the name is an email" do
      let(:name) { "test@example.org" }

      it { is_expected.not_to be_valid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when the password is weak" do
      let(:password) { "aaaabbbbcccc" }

      it { is_expected.not_to be_valid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.not_to be_valid }
    end

    describe "#newsletter_at" do
      subject { form.newsletter_at }

      let(:current_time) { Time.current }

      it { is_expected.to be_between(current_time - 1.minute, current_time + 1.minute) }

      context "when newsletter was not ordered" do
        let(:newsletter) { "0" }

        it { is_expected.to be_nil }
      end
    end

    describe "nickname" do
      let(:name) { "justme" }

      context "when the nickname already exists" do
        context "and a user has the nickname" do
          let!(:another_user) { create(:user, organization:, nickname: name) }

          it { is_expected.to be_valid }

          it "adds a suffix in the nickname" do
            expect(subject.nickname).to eq("justme_2")
          end

          context "and is pending to accept the invitation" do
            let!(:another_user) { create(:user, organization:, nickname: name, invitation_token: "foo", invitation_accepted_at: nil) }

            it { is_expected.to be_valid }
          end
        end

        context "and a user_group has the nickname" do
          let!(:user_group) { create(:user_group, organization:, nickname: name) }

          it { is_expected.to be_valid }
        end
      end

      context "when the nickname is too long" do
        let(:name) { "verylongnicknamethatcreatesanerror" }

        it { is_expected.to be_valid }

        it "truncates the nickname" do
          expect(subject.nickname).to eq("verylongnicknamethat")
        end
      end

      context "when the name has spaces" do
        let(:name) { "test example" }

        it { is_expected.to be_valid }

        it "replaces the space in the nickname" do
          expect(subject.nickname).to eq("test_example")
        end
      end
    end
  end
end
