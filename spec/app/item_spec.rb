# frozen_string_literal: true

require 'spec_helper'

describe App::Item, type: :model do
  let(:attrs) do
    {
      location: :remote,
      reference: rand(1..1000),
      status: 'enabled',
      description: 'Some description'
    }
  end

  subject { described_class.new(attrs) }

  describe '.new' do
    context 'with valid attributes' do
      it 'creates an item' do
        expect(subject).to be
      end
    end

    context 'when location is not included in allowed locations' do
      it 'raises App::OutOfRangeError' do
        attrs[:location] = 'another'
        expect { subject }.to raise_error(
          App::OutOfRangeError,
          /Please provide proper location/
        )
      end
    end

    context 'when reference is not a positive number' do
      it 'raises App::ArgumentTypeError' do
        attrs[:reference] = 'another'
        expect { subject }.to raise_error(
          App::ArgumentTypeError,
          /Please provide proper reference id/
        )
      end
    end

    context 'when status is not included in allowed statuses' do
      it 'raises OutOfRangeError' do
        attrs[:status] = 'another'
        expect { subject }.to raise_error(
          App::OutOfRangeError,
          /Please provide valid status/
        )
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash with reference, status, and description' do
      expect(subject.to_h).to include(
        reference: attrs[:reference],
        status: status_mapping(attrs),
        description: attrs[:description]
      )
    end
  end

  describe '#display_difference' do
    let(:item) { described_class.new(attrs) }

    context 'for items with different references' do
      let(:other) do
        described_class.new(
          location: :local,
          reference: rand(1..1000),
          status: 'paused',
          description: 'Some description'
        )
      end

      it 'returns nil' do
        expect(item.display_difference(other)).to be_nil
      end
    end
    context 'for items with same references' do
      let(:other) do
        described_class.new(
          location: :local,
          reference: item.reference,
          status: 'deleted',
          description: 'Some  other description'
        )
      end

      it 'returns differences' do
        expect(item.display_difference(other)).to include(
          remote_reference: item.reference,
          discrepancies: {
            description: {
              local: other.description,
              remote: item.description
            },
            status: {
              local: other.status,
              remote: item.status
            }
          }
        )
      end
    end

    context 'for items with same reference' do
    end
  end
end

def status_mapping(attrs = {})
  App::Item::STATUSES.dig(attrs[:location].to_sym, attrs[:status].to_sym)
end
