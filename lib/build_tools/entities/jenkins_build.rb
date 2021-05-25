# frozen_string_literal: true

module BuildTools
  module Entities
    class JenkinsBuild < Struct

      module Statuses
        SUCCESS = 'SUCCESS'
        ABORTED = 'ABORTED'
        FAILURE = 'FAILURE'
        BLANK = ''
      end

      attribute :id, Types::Coercible::Integer
      attribute :result, Types::Coercible::String
      attribute :duration, Types::Integer #in seconds
      attribute :estimated_duration, Types::Integer # in seconds

      def success?
        result == Statuses::SUCCESS
      end

      def no_longer_running?
        result != Statuses::BLANK
      end
    end
  end
end
