# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      module Concerns
        # Scopes for proposals, coauthorships, and proposal votes.
        module ProposalQueries
          extend ActiveSupport::Concern

          private

          def proposal_ids
            @proposal_ids ||= fetch_proposal_ids
          end

          def coauthorships_scope
            Decidim::Coauthorship
              .where(coauthorable_type: "Decidim::Proposals::Proposal", coauthorable_id: proposal_ids)
              .where(decidim_author_type: "Decidim::UserBaseEntity")
              .where.not(decidim_author_id: nil)
          end

          def proposal_votes_scope
            Decidim::Proposals::ProposalVote
              .where(decidim_proposal_id: proposal_ids)
          end

          def fetch_proposal_ids
            ids = component_ids_for("proposals")
            return [] if ids.empty?

            Decidim::Proposals::Proposal
              .where(decidim_component_id: ids)
              .published
              .not_hidden
              .pluck(:id)
          end
        end
      end
    end
  end
end
