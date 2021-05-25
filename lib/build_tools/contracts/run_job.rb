# frozen_string_literal: true

module BuildTools
  module Contracts
    class RunJob < Contract
      params do
        required(:job).filled(:string)
        required(:env).filled(:string)
        required(:params).filled(:hash)
      end

      rule(:env) do
        key.failure('must be a known environment') unless Environments::ALLOWED.include?(value)
      end
    end
  end
end
