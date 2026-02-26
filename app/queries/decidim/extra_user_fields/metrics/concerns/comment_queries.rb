# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      module Concerns
        # Comments scope across commentable resource types (proposals, budget projects).
        # Depends on ProposalQueries and BudgetQueries.
        module CommentQueries
          extend ActiveSupport::Concern

          private

          def comments_scope
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
end
