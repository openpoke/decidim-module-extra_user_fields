# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # A command with all the business logic when updating organization's extra user fields in signup form
      class UpdateExtraUserFields < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_extra_user_fields!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_extra_user_fields!
          Decidim.traceability.update!(
            form.current_organization,
            form.current_user,
            extra_user_fields:
          )
        end

        def extra_user_fields
          standard_fields.merge(
            "enabled" => form.enabled.presence || false,
            "phone_number" => phone_number_fields,
            "underage" => { "enabled" => form.underage || false },
            "underage_limit" => form.underage_limit || Decidim::ExtraUserFields.underage_limit,
            "select_fields" => form.select_fields,
            "boolean_fields" => form.boolean_fields.to_a,
            "text_fields" => form.text_fields
          )
        end

        def standard_fields
          (Decidim::ExtraUserFields::PROFILE_FIELDS - %w(phone_number)).index_with do |field|
            { "enabled" => form.public_send(field).presence || "disabled" }
          end
        end

        def phone_number_fields
          {
            "enabled" => form.phone_number.presence || "disabled",
            "pattern" => form.phone_number_pattern.presence,
            "placeholder" => form.phone_number_placeholder.presence
          }
        end
      end
    end
  end
end
