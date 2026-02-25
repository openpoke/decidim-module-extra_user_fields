# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Base class for all insight metrics.
      # Each subclass returns a hash of { user_id => count } scoped to a participatory space.
      class BaseMetric
        def initialize(participatory_space)
          @participatory_space = participatory_space
        end

        # @return [Hash{Integer => Integer}] user_id => count
        def call
          raise NotImplementedError, "#{self.class}#call must be implemented"
        end

        private

        attr_reader :participatory_space

        def component_ids_for(manifest_name)
          participatory_space.components.where(manifest_name: manifest_name).published.pluck(:id)
        end

        def proposal_ids
          @proposal_ids ||= fetch_proposal_ids
        end

        def budget_ids
          @budget_ids ||= fetch_budget_ids
        end

        # Find comments on resources within this space.
        # Returns an ActiveRecord scope (not plucked).
        def comments_in_space
          @comments_in_space ||= build_comments_scope
        end

        def budget_project_ids
          @budget_project_ids ||= fetch_budget_project_ids
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

        def build_comments_scope
          scopes = []

          if proposal_ids.any?
            scopes << Decidim::Comments::Comment.where(
              decidim_root_commentable_type: "Decidim::Proposals::Proposal",
              decidim_root_commentable_id: proposal_ids
            )
          end

          if budget_project_ids.any?
            scopes << Decidim::Comments::Comment.where(
              decidim_root_commentable_type: "Decidim::Budgets::Project",
              decidim_root_commentable_id: budget_project_ids
            )
          end

          return Decidim::Comments::Comment.none if scopes.empty?

          scopes.reduce(:or)
        end
      end
    end
  end
end
