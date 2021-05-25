# frozen_string_literal: true

module BuildTools
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
        base_url = yield @form_base_url.call(
          job: valid_args[:job],
          env: valid_args[:env]
        )

        body = transform_params(valid_args[:params])
        response = @http.post("#{base_url}/#{TAIL}", body: body)

        if response.status.success?
          Success(:ok)
        else
          Failure("jenkins server returned request code #{response.code}")
        end
      end

      private

      def transform_params(params)
        URI.encode_www_form(params)
      end
    end
  end
end
