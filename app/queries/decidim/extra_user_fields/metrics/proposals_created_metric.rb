# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts proposals created by each user within the participatory space.
      class ProposalsCreatedMetric < BaseMetric
        def call
          return {} if proposal_ids.empty?

          Decidim::Coauthorship
            .where(coauthorable_type: "Decidim::Proposals::Proposal", coauthorable_id: proposal_ids)
            .where(decidim_author_type: "Decidim::UserBaseEntity")
            .where.not(decidim_author_id: nil)
            .group(:decidim_author_id)
            .count
        end
      end
    end
  end
end
