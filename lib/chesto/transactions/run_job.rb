# frozen_string_literal: true

module Chesto
  module Transactions
    class RunJob
      include Transaction

      TAIL = 'buildWithParameters'.freeze

      def initialize(deps={})
        @http = deps[:http] || HTTP.basic_auth(AUTH)
        @form_base_url = deps[:form_base_url] || Operations::FormBaseUrl.instance
        @contract = deps[:schema] || Contracts::RunJob.new
        @apply_contract = deps[:apply_contract] || ApplyContract.instance
      end

      def call(args)
        valid_args = yield @apply_contract.call(args, contract: @contract)
        base_url = yield @form_base_url.call(valid_args[:job])

        yield validate_if_token_present
        body = yield transform_params(valid_args[:params])
        response = @http.post("#{base_url}/#{TAIL}", body: body)

        if response.status.success?
          Success(:ok)
        else
          Failure("jenkins server returned request code #{response.code}")
        end
      end

      private

      def validate_if_token_present
        Success(:ok) if STRING_PRESENT.call(ENV['JENKINS_JOB_TOKEN'])
      end

      def transform_params(params)
        if params.is_a?(Hash)
          with_token = params.merge(token: ENV['JENKINS_JOB_TOKEN'])
          uri_encoded = URI.encode_www_form(with_token)

          Success(uri_encoded)
        elsif params.is_a?(String)
          with_token = "#{params}&token=#{ENV['JENKINS_JOB_TOKEN']}"
          normalized = URI.decode_www_form(with_token)
          uri_encoded = URI.encode_www_form(normalized)

          Success(uri_encoded)
        else
          Failure(:invalid_params)
        end
      end
    end
  end
end
