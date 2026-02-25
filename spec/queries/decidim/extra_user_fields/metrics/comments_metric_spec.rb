# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe CommentsMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no comments" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have commented on proposals" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create_list(:comment, 3, commentable: proposal, author: user1)
        create(:comment, commentable: proposal, author: user2)
      end

      it "returns the comment count per user" do
        result = subject.call
        expect(result[user1.id]).to eq(3)
        expect(result[user2.id]).to eq(1)
      end
    end
  end
end
