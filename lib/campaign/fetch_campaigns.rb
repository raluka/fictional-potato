# frozen_string_literal: true

module Campaign
  class FetchCampaigns
    ALL_LOCAL = [
      {
        id: 11,
        job_id: 1,
        external_reference: 1,
        status: 'active',
        ad_description: 'Description for campaign 11'
      },
      {
        id: 12,
        job_id: 1,
        external_reference: 2,
        status: 'paused',
        ad_description: 'Description for campaign 112'
      },
      {
        id: 13,
        job_id: 1,
        external_reference: 3,
        status: 'deleted',
        ad_description: 'Description for campaign'
      }
    ].freeze

    def self.call(reference_ids:)
      new(reference_ids).call
      # Get collection from database filtered by reference_ids
    end

    def call
      fetch_campaigns
    end

    private

    attr_reader :reference_ids

    def initialize(reference_ids)
      @reference_ids = reference_ids
    end

    def fetch_campaigns
      # This is hardcoded response of local campaigns, for proof of concept sake
      # Ideally, here we should return from database a collection of campaigns
      # filtered by reference_ids
      # Campaigns.
      # select(:external_reference, :status, ad_description).
      # where(reference_id: reference_ids).
      # all
      ALL_LOCAL
    end
  end
end
