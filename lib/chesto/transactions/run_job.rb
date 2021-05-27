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

        form_params = yield transform_params(valid_args[:params])
        response = @http.post("#{base_url}/#{TAIL}", form: form_params)

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
          symbolized = JSON.parse(JSON[params], symbolize_names: true)
          with_token = symbolized.merge(token: ENV['JENKINS_JOB_TOKEN'])

          Success(with_token)
        else
          Failure(:invalid_params)
        end
      end
    end
  end
end
