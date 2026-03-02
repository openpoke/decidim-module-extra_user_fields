# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts unique participants — users who have any activity in the participatory space.
      # Includes: proposal authors, proposal supporters, commenters, budget voters.
      # Each user is counted once regardless of how many activities they have.
      class ParticipantsMetric < BaseMetric
        include Concerns::ProposalQueries
        include Concerns::BudgetQueries
        include Concerns::CommentQueries

        def call
          user_ids = Set.new

          if has_proposals?
            user_ids.merge(coauthorships_scope.distinct.pluck(:decidim_author_id))
            user_ids.merge(proposal_votes_scope.distinct.pluck(:decidim_author_id))
          end
          user_ids.merge(comments_scope.where(decidim_author_type: "Decidim::UserBaseEntity").distinct.pluck(:decidim_author_id))
          user_ids.merge(budget_orders_scope.distinct.pluck(:decidim_user_id)) if has_budgets?

          user_ids.index_with { 1 }
        end
      end
    end
  end
end
