# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts unique participants — users who authored any resource (proposal, comment, budget vote)
      # within the given participatory space. Each user is counted once.
      class ParticipantsMetric < BaseMetric
        def call
          user_ids = Set.new

          user_ids.merge(proposal_author_ids)
          user_ids.merge(comment_author_ids)
          user_ids.merge(budget_voter_ids)

          user_ids.index_with { 1 }
        end

        private

        def proposal_author_ids
          return [] if proposal_ids.empty?

          Decidim::Coauthorship
            .where(coauthorable_type: "Decidim::Proposals::Proposal", coauthorable_id: proposal_ids)
            .where(decidim_author_type: "Decidim::UserBaseEntity")
            .where.not(decidim_author_id: nil)
            .distinct.pluck(:decidim_author_id)
        end

        def comment_author_ids
          comments_in_space
            .where(decidim_author_type: "Decidim::UserBaseEntity")
            .distinct.pluck(:decidim_author_id)
        end

        def budget_voter_ids
          return [] if budget_ids.empty?

          Decidim::Budgets::Order
            .where(decidim_budgets_budget_id: budget_ids)
            .where.not(checked_out_at: nil)
            .distinct.pluck(:decidim_user_id)
        end
      end
    end
  end
end
