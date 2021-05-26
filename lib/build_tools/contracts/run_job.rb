# frozen_string_literal: true

module BuildTools
  module Contracts
    class RunJob < Contract
      params do
        required(:job).filled(:string)
        required(:params).filled
      end
    end
  end
end
