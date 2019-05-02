# frozen_string_literal: true

require 'spec_helper'

describe Campaign::FetchCampaigns do
  describe '.call' do
    let(:ids) { [1, 2, 3, 4, 5] }
    it 'returns collection of local campaign filtered by reference ids' do
      expect(described_class.call(reference_ids: ids)).to eq(
        Campaign::FetchCampaigns::ALL_LOCAL
      )
    end
  end
end
