# frozen_string_literal: true

require_relative 'chesto/version'

require 'dry/monads/result'
require 'dry/monads/do'
require 'dry/types'
require 'dry/struct'
require 'dry/validation'
require 'ruby-progressbar'

require 'http'
require 'json'

module Chesto
  class Error < StandardError; end

  AUTH = {
    user: ENV['JENKINS_DEPLOY_USER'],
    pass: ENV['JENKINS_DEPLOY_API_KEY']
  }.freeze

  module Transaction
    def self.included(base)
      base.include(Dry::Monads::Result::Mixin)
      base.include(Dry::Monads::Do.for(:call))
    end
  end

  module Operation
    def self.included(base)
      base.include(Dry::Monads::Result::Mixin)
    end
  end

  class Struct < Dry::Struct
  end

  module Types
    include Dry.Types()
  end

  class Contract < Dry::Validation::Contract
  end

  class ApplyContract
    include Singleton
    include Operation

    def call(params, contract:)
      result = contract.call(params)
      errors = result.errors.to_h

      if errors.empty?
        Success(result.to_h)
      else
        Failure(errors)
      end
    end
  end

  STRING_PRESENT = lambda do |string|
    !string.to_s.empty?
  end.freeze
end

require_relative 'chesto/entities/jenkins_build'
require_relative 'chesto/operations/form_base_url'
require_relative 'chesto/transactions/get_last_build'

require_relative 'chesto/contracts/run_job'
require_relative 'chesto/transactions/run_job'
require_relative 'chesto/transactions/run_job_and_wait'
