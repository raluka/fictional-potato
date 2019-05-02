# frozen_string_literal: true

module App
  class OutOfRangeError < StandardError; end
  class ArgumentTypeError < StandardError; end

  class Item
    STATUSES = {
      remote: { enabled: 'active', disabled: 'paused', deleted: 'deleted' },
      local: { active: 'active', paused: 'paused', deleted: 'deleted' }
    }.freeze

    ALLOWED_LOCATIONS = %i[local remote].freeze

    attr_reader :location, :reference, :description, :status

    def initialize(attrs = {})
      validate_attributes(attrs[:location], attrs[:reference], attrs[:status])

      @location = attrs[:location]
      @reference = Integer(attrs[:reference])
      @status = STATUSES.dig(attrs[:location].to_sym, attrs[:status].to_sym)
      @description = attrs[:description]
    end

    def display_difference(other)
      return unless to_h != other.to_h && reference == other.reference

      {
        remote_reference: reference,
        discrepancies: calculate_differences(other)
      }
    end

    def to_h
      { reference: reference, status: status, description: description }
    end

    private

    def validate_attributes(location, reference, status)
      validate_location(location)
      validate_reference(reference)
      validate_status(location, status)
    end

    def validate_location(location)
      unless ALLOWED_LOCATIONS.include?(location.to_sym)
        raise App::OutOfRangeError, 'Please provide proper location'
      end
    end

    def validate_reference(reference)
      unless reference.to_i.positive?
        raise App::ArgumentTypeError, 'Please provide proper reference id'
      end
    end

    def validate_status(location, status)
      unless STATUSES.dig(location.to_sym, status.to_sym)
        raise App::OutOfRangeError, 'Please provide valid status'
      end
    end


    def calculate_differences(other)
      h = {}
      status_diff(h, other)
      description_diff(h, other)
      h
    end

    def status_diff(diff_hash, other)
      return unless status != other.status

      diff_hash[:status] = { other.location => other.status, location => status }
    end

    def description_diff(diff_hash, other)
      return unless description != other.description

      diff_hash[:description] = {
        other.location => other.description,
        location => description
      }
    end
  end
end
