# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts checked-out budget orders (votes) by each user within the participatory space.
      class BudgetVotesMetric < BaseMetric
        def call
          return {} if budget_ids.empty?

          Decidim::Budgets::Order
            .where(decidim_budgets_budget_id: budget_ids)
            .where.not(checked_out_at: nil)
            .group(:decidim_user_id)
            .count
        end
      end
    end
  end
end
