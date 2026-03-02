# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      module Concerns
        # Scopes for budgets, projects, and checked-out budget orders.
        module BudgetQueries
          extend ActiveSupport::Concern

          private

          def budget_ids
            @budget_ids ||= fetch_budget_ids
          end

          def budget_project_ids
            @budget_project_ids ||= fetch_budget_project_ids
          end

          def budget_orders_scope
            Decidim::Budgets::Order
              .where(decidim_budgets_budget_id: budget_ids)
              .where.not(checked_out_at: nil)
          end

          def fetch_budget_ids
            ids = component_ids_for("budgets")
            return [] if ids.empty?

            Decidim::Budgets::Budget
              .where(decidim_component_id: ids)
              .pluck(:id)
          end

          def fetch_budget_project_ids
            return [] if budget_ids.empty?

            Decidim::Budgets::Project
              .where(decidim_budgets_budget_id: budget_ids)
              .pluck(:id)
          end
        end
      end
    end
  end
end
