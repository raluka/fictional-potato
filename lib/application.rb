# frozen_string_literal: true

$LOAD_PATH.push File.expand_path(__dir__)
require 'api/fetch_campaigns'
require 'campaign/fetch_campaigns'
require 'httparty'

module Application
  def self.run!
    url = 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'
    api_response = API::FetchCampaigns.call(url: url)
    ids = api_response.map { |item| item['reference']&.to_i }.compact
    local_campaigns = Campaign::FetchCampaigns.call(reference_ids: ids)
  end
end

begin
  Application.run!
rescue StandardError => e
  Logger.new(STDOUT).error(e.message)
end
