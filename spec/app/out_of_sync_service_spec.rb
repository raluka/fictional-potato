# frozen_string_literal: true

require 'spec_helper'

describe App::OutOfSyncService, type: :service do
  describe '.call' do
    let(:url) { 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df' }
    let(:api_response) do
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
    let(:expected_output) do
      [
        {
          remote_reference: 2,
          discrepancies: {
            description: {
              local: 'Description for campaign 112',
              remote: 'Description for campaign 12'
            }
          }
        },
        {
          remote_reference: 3,
          discrepancies: {
            description:
              {
                local: 'Description for campaign',
                remote: 'Description for campaign 13'
              },
            status: {
              local: 'deleted',
              remote: 'active'
            }
          }
        }
      ]
    end

    subject { described_class.call(url) }

    before do
      stub_request(:get, url)
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: api_response.to_json, headers: {})
    end

    it 'returns discrepancies  logs' do
      is_expected.to eq(expected_output)
    end

    context 'with missing url' do
      it 'raises MalformedUrlError' do
        expect { described_class.new(nil) }.to raise_error(
          API::MalformedUrlError,
          /Missing url/
        )
      end
    end
  end
end
