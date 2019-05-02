# frozen_string_literal: true

require 'spec_helper'

describe API::FetchCampaigns do
  describe '.call' do
    context 'with missing url' do
      it 'raises MalformedUrlError' do
        expect { described_class.new('') }.to raise_error(
          API::MalformedUrlError,
          /Missing url/
        )
      end
    end

    context 'with existing url' do
      let!(:url) { 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df' }

      context 'when API response is 200' do
        let(:expected_response) do
          { 'ads' =>
            [
              {
                'reference' => '1',
                'status' => 'enabled',
                'description' => 'Description for campaign 11'
              },
              {
                'reference' => '2',
                'status' => 'disabled',
                'description' => 'Description for campaign 12'
              },
              {
                'reference' => '3',
                'status' => 'enabled',
                'description' => 'Description for campaign 13'
              }
            ] }
        end

        before do
          stub_request(:get, url)
            .with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'
              }
            )
            .to_return(status: 200, body: expected_response.to_json, headers: {})
        end

        it 'returns an instance with attributes' do
          expect(described_class.call(url: url)).to eq(expected_response.dig('ads'))
        end
      end

      context 'when API response is 500' do
        before do
          stub_request(:get, url)
            .with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'
              }
            )
            .to_return(status: 500, body: 'Internal Server Error', headers: {})
        end

        it 'raises ApiServerError' do
          expect { described_class.call(url: url) }.to raise_error(
            API::ApiServerError,
            /Failed to fetch data from API/
          )
        end
      end
    end
  end
end
