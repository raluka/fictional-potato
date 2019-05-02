# frozen_string_literal: true

$LOAD_PATH.push File.expand_path(__dir__)
require 'api/fetch_campaigns'
require 'campaign/fetch_campaigns'
require 'app/item'
require 'httparty'

module Application
  def self.run!
    url = 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'
    remote_campaigns = API::FetchCampaigns.call(url: url)
    ids = remote_campaigns.map { |item| item['reference']&.to_i }.compact
    local_campaigns = Campaign::FetchCampaigns.call(reference_ids: ids)
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
end

begin
  Application.run!
rescue StandardError => e
  Logger.new(STDOUT).error(e.message)
end
