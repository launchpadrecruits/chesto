# frozen_string_literal: true

module BuildTools
  module Transactions
    class GetLastBuild
      include Transaction

      TAIL = 'lastBuild/api/json'.freeze

      def initialize(deps = {})
        @http = deps[:http] || HTTP.basic_auth(AUTH)
        @json = deps[:json] || JSON
        @form_base_url = deps[:form_base_url] || Operations::FormBaseUrl.instance
      end

      def call(job:, env:)
        base_url = yield @form_base_url.call(job: job, env: env)
        response = @http.get("#{base_url}/#{TAIL}")

        if response.status.success?
          raw_body = @json.parse(response.to_s, symbolize_names: true)
          transformed_body = transform_build_hash(raw_body)
          build = Entities::JenkinsBuild.new(transformed_body)

          Success(build)
        else
          Failure(request_error: "jenkins server returned request code #{response.code}")
        end
      end

      private

      # The duration that is received is in milliseconds so convert
      # to seconds
      def transform_build_hash(raw_body)
        estimated_duration_in_seconds = convert_to_seconds(raw_body[:estimatedDuration])
        duration_in_seconds = convert_to_seconds(raw_body[:duration])

        raw_body.merge(
          estimated_duration: estimated_duration_in_seconds,
          duration: duration_in_seconds
        )
      end

      def convert_to_seconds(milliseconds)
        if milliseconds
          milliseconds / 1000
        end
      end
    end
  end
end
