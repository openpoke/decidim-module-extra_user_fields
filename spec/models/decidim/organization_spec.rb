# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization do
    subject(:organization) { build(:organization, extra_user_fields:) }

    let(:extra_user_fields) do
      {
        "enabled" => extra_user_field,
        "date_of_birth" => date_of_birth
      }
    end
    let(:extra_user_field) { true }
    let(:date_of_birth) do
      { "enabled" => true }
    end
    let(:omniauth_secrets) do
      {
        facebook: {
          enabled: true,
          app_id: "fake-facebook-app-id",
          app_secret: "fake-facebook-app-secret"
        },
        twitter: {
          enabled: true,
          api_key: "fake-twitter-api-key",
          api_secret: "fake-twitter-api-secret"
        },
        google_oauth2: {
          enabled: true,
          client_id: nil,
          client_secret: nil
        },
        test: {
          enabled: true,
          icon: "tools-line"
        }
      }
    end

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::OrganizationPresenter
    end

    describe "has an association for scopes" do
      subject(:organization_scopes) { organization.scopes }

      let(:scopes) { create_list(:scope, 2, organization:) }

      it { is_expected.to match_array(scopes) }
    end

    describe "has an association for scope types" do
      subject(:organization_scopes_types) { organization.scope_types }

      let(:scope_types) { create_list(:scope_type, 2, organization:) }

      it { is_expected.to match_array(scope_types) }
    end

    describe "validations" do
      it "default locale should be included in available locales" do
        subject.available_locales = [:ca, :es]
        subject.default_locale = :en
        expect(subject).not_to be_valid
      end
    end

    describe "enabled omniauth providers" do
      subject(:enabled_providers) { organization.enabled_omniauth_providers }

      let!(:previous_omniauth_providers) { Decidim.omniauth_providers }

      after do
        Decidim.omniauth_providers = previous_omniauth_providers
      end

      context "when omniauth_settings are nil" do
        context "when providers are enabled" do
          before do
            allow(Decidim).to receive(:omniauth_providers).and_return(omniauth_secrets)
          end

          it "returns providers enabled" do
            expect(enabled_providers).to eq(omniauth_secrets)
          end
        end

        context "when providers are not enabled" do
          before do
            allow(Decidim).to receive(:omniauth_providers).and_return({})
          end

          it "returns no providers" do
            expect(enabled_providers).to be_empty
          end
        end
      end

      context "when it's overriden" do
        let(:organization) { create(:organization) }
        let(:omniauth_settings) do
          {
            "omniauth_settings_facebook_enabled" => true,
            "omniauth_settings_facebook_app_id" => Decidim::AttributeEncryptor.encrypt("overriden-app-id"),
            "omniauth_settings_facebook_app_secret" => Decidim::AttributeEncryptor.encrypt("overriden-app-secret"),
            "omniauth_settings_google_oauth2_enabled" => true,
            "omniauth_settings_google_oauth2_client_id" => Decidim::AttributeEncryptor.encrypt("overriden-client-id"),
            "omniauth_settings_google_oauth2_client_secret" => Decidim::AttributeEncryptor.encrypt("overriden-client-secret"),
            "omniauth_settings_twitter_enabled" => false
          }
        end

        before { organization.update!(omniauth_settings:) }

        it "returns only the enabled settings" do
          expect(subject[:facebook][:app_id]).to eq("overriden-app-id")
          expect(subject[:twitter]).to be_nil
          expect(subject[:google_oauth2][:client_id]).to eq("overriden-client-id")
        end
      end
    end

    describe "#static_pages_accessible_for" do
      it_behaves_like "accessible static pages" do
        let(:actual_page_ids) do
          organization.static_pages_accessible_for(user).pluck(:id)
        end
      end
    end

    describe "#extra_user_fields_enabled?" do
      it "returns true" do
        expect(subject).to be_extra_user_fields_enabled
      end

      context "when extra user fields are disabled" do
        let(:extra_user_field) { false }

        it "returns true" do
          expect(subject).not_to be_extra_user_fields_enabled
        end
      end
    end

    describe "#force_extra_user_fields?" do
      context "when extra user fields are enabled and force flag is on" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "force_extra_user_fields" => true,
            "date_of_birth" => { "enabled" => true }
          }
        end

        it "returns true" do
          expect(subject).to be_force_extra_user_fields
        end
      end

      context "when force flag is off" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "force_extra_user_fields" => false,
            "date_of_birth" => { "enabled" => true }
          }
        end

        it "returns false" do
          expect(subject).not_to be_force_extra_user_fields
        end
      end

      context "when extra user fields are disabled" do
        let(:extra_user_fields) do
          {
            "enabled" => false,
            "force_extra_user_fields" => true,
            "date_of_birth" => { "enabled" => true }
          }
        end

        it "returns false" do
          expect(subject).not_to be_force_extra_user_fields
        end
      end
    end

    describe "#extra_user_fields_complete?" do
      let(:user) { build(:user, organization:, extended_data:) }
      let(:extra_user_fields) do
        {
          "enabled" => true,
          "date_of_birth" => { "enabled" => true },
          "country" => { "enabled" => true },
          "gender" => { "enabled" => false }
        }
      end

      context "when all activated fields are filled in" do
        let(:extended_data) { { "date_of_birth" => "2000-01-01", "country" => "ES" } }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when an activated field is missing" do
        let(:extended_data) { { "date_of_birth" => "2000-01-01" } }

        it "returns false" do
          expect(subject.extra_user_fields_complete?(user)).to be false
        end
      end

      context "when a non-activated field is missing" do
        let(:extended_data) { { "date_of_birth" => "2000-01-01", "country" => "ES" } }

        it "returns true even without gender" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when no fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false },
            "country" => { "enabled" => false }
          }
        end
        let(:extended_data) { {} }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when select_fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false },
            "select_fields" => ["participant_type"]
          }
        end

        context "when user has filled the select field" do
          let(:extended_data) { { "select_fields" => { "participant_type" => "individual" } } }

          it "returns true" do
            expect(subject.extra_user_fields_complete?(user)).to be true
          end
        end

        context "when user has not filled the select field" do
          let(:extended_data) { { "select_fields" => {} } }

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when user has no select_fields data at all" do
          let(:extended_data) { {} }

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end
      end

      context "when text_fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false },
            "text_fields" => ["motto"]
          }
        end

        before do
          allow(Decidim::ExtraUserFields).to receive(:text_fields).and_return(enabled_text_fields)
        end

        context "when text field is mandatory" do
          let(:enabled_text_fields) { { motto: true } }

          context "when user has filled the text field" do
            let(:extended_data) { { "text_fields" => { "motto" => "Carpe diem" } } }

            it "returns true" do
              expect(subject.extra_user_fields_complete?(user)).to be true
            end
          end

          context "when user has not filled the text field" do
            let(:extended_data) { { "text_fields" => {} } }

            it "returns false" do
              expect(subject.extra_user_fields_complete?(user)).to be false
            end
          end

          context "when user has no text_fields data at all" do
            let(:extended_data) { {} }

            it "returns false" do
              expect(subject.extra_user_fields_complete?(user)).to be false
            end
          end
        end

        context "when text field is optional" do
          let(:enabled_text_fields) { { motto: false } }

          context "when user has not filled the text field" do
            let(:extended_data) { { "text_fields" => {} } }

            it "returns true" do
              expect(subject.extra_user_fields_complete?(user)).to be true
            end
          end

          context "when user has no text_fields data at all" do
            let(:extended_data) { {} }

            it "returns true" do
              expect(subject.extra_user_fields_complete?(user)).to be true
            end
          end
        end
      end

      context "when boolean_fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false },
            "boolean_fields" => ["ngo"]
          }
        end
        let(:extended_data) { {} }

        it "returns true because boolean fields do not block completion" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when both standard and collection fields are activated" do
        let(:enabled_text_fields) { { motto: true } }
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "country" => { "enabled" => true },
            "date_of_birth" => { "enabled" => false },
            "select_fields" => ["participant_type"],
            "text_fields" => ["motto"]
          }
        end

        before do
          allow(Decidim::ExtraUserFields).to receive(:text_fields).and_return(enabled_text_fields)
        end

        context "when all fields are filled" do
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => { "motto" => "Carpe diem" }
            }
          end

          it "returns true" do
            expect(subject.extra_user_fields_complete?(user)).to be true
          end
        end

        context "when standard field is missing" do
          let(:extended_data) do
            {
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => { "motto" => "Carpe diem" }
            }
          end

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when select field is missing" do
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => {},
              "text_fields" => { "motto" => "Carpe diem" }
            }
          end

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when mandatory text field is missing" do
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => {}
            }
          end

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when optional text field is missing" do
          let(:enabled_text_fields) { { motto: false } }
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => {}
            }
          end

          it "returns true" do
            expect(subject.extra_user_fields_complete?(user)).to be true
          end
        end
      end
    end

    describe "#activated_extra_field?" do
      it "returns the value of given key" do
        expect(subject).to be_activated_extra_field(:date_of_birth)
      end

      context "when given key doesn't exist in hash" do
        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:unknown)
        end
      end

      context "when value for given key is nil" do
        let(:date_of_birth) { nil }

        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:date_of_birth)
        end
      end
    end
  end
end
