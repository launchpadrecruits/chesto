# frozen_string_literal: true

module BuildTools
  module Operations
    class FormBaseUrl
      include Operation
      include Singleton

      def call(env:, job:)
        Success("#{ENV['JENKINS_URL']}/#{JOB_PATHS[env]}/#{job}")
      end
    end
  end
end
