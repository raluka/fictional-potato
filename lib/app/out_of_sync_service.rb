# frozen_string_literal: true

module App
  class OutOfSyncService
    def self.call(url)
      new(url).call
    end

    def call
      remote_campaigns = fetch_api_campaigns
      ids = reference_ids(remote_campaigns)
      local_campaigns = fetch_local_campaigns(ids)

      remote_items = remote_campaigns.map do |resp|
        App::Item.new(
          location: :remote,
          reference: resp.dig('reference'),
          status: resp.dig('status').to_sym,
          description: resp.dig('description')
        )
      end

      local_items = local_campaigns.map do |c|
        App::Item.new(
          location: :local,
          reference: c.dig(:external_reference),
          status: c.dig(:status).to_sym,
          description: c.dig(:ad_description)
        )
      end

      items_values = (local_items + remote_items).group_by(&:reference).values
      logs = items_values.map do |grouped_items|
        first_item, second_item = *grouped_items
        first_item.display_difference(second_item)
      end.compact

      Logger.new(STDOUT).info(logs)
      logs
    end

    private

    attr_reader :url

    def initialize(url)
      raise API::MalformedUrlError, 'Missing url' if url.nil? || url.empty?

      @url = url
    end

    def fetch_local_campaigns(reference_ids)
      Campaign::FetchCampaigns.call(reference_ids: reference_ids)
    end

    def fetch_api_campaigns
      API::FetchCampaigns.call(url: url)
    end

    def reference_ids(api_response)
      api_response.map { |item| item['reference']&.to_i }.compact
    end
  end
end
