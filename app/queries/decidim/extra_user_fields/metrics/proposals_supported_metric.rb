# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts proposal votes (supports) made by each user within the participatory space.
      class ProposalsSupportedMetric < BaseMetric
        def call
          return {} if proposal_ids.empty?

          Decidim::Proposals::ProposalVote
            .where(decidim_proposal_id: proposal_ids)
            .group(:decidim_author_id)
            .count
        end
      end
    end
  end
end
