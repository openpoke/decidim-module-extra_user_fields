# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts proposal votes (supports) made by each user within the participatory space.
      class ProposalsSupportedMetric < BaseMetric
        include Concerns::ProposalQueries

        def call
          return {} if proposal_ids.empty?

          proposal_votes_scope.group(:decidim_author_id).count
        end
      end
    end
  end
end
