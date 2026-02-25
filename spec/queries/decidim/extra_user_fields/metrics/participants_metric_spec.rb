# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe ParticipantsMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no activities" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have created proposals" do
      before do
        create(:proposal, :published, component: proposal_component, users: [user1])
        create(:proposal, :published, component: proposal_component, users: [user2])
      end

      it "returns each user counted once" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
        expect(result[user2.id]).to eq(1)
      end
    end

    context "when a user has multiple activities" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create(:comment, commentable: proposal, author: user1)
      end

      it "still counts the user only once" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
      end
    end

    context "when users voted on budgets" do
      let(:budgets_component) { create(:budgets_component, :published, participatory_space: participatory_process) }
      let(:budget) { create(:budget, component: budgets_component) }

      before do
        order = create(:order, :with_projects, budget:, user: user1)
        order.update!(checked_out_at: Time.current)
      end

      it "includes the voter" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
      end
    end
  end
end
