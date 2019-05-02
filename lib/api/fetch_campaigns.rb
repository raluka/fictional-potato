# frozen_string_literal: true

module API
  class MalformedUrlError < StandardError; end
  class ApiServerError < StandardError; end

  class FetchCampaigns
    def self.call(url:)
      new(url).call
    end

    def call
      result = HTTParty.get(url).response
      raise ApiServerError, 'Failed to fetch data from API' if result.code.match? '500'

      JSON.parse(result.body).dig('ads')
    end

    private

    attr_reader :url

    def initialize(url)
      raise MalformedUrlError, 'Missing url' if url.nil? || url.empty?

      @url = url
    end
  end
end
