# frozen_string_literal: true

require_relative "build_tools/version"

require 'dry/monads/result'
require 'dry/monads/do'
require 'dry/types'
require 'dry/struct'
require 'dry/validation'

require 'http'
require 'json'

module BuildTools
  class Error < StandardError; end

  module Environments
    DEV = 'dev'.freeze

    ALLOWED = [DEV].freeze
  end

  AUTH = {
    user: ENV['JENKINS_DEPLOY_USER'],
    pass: ENV['JENKINS_DEPLOY_API_KEY']
  }.freeze

  JOB_PATHS = {
    Environments::DEV => 'job/launchpadrecruits-main/job/unrestricted/job'
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
end

require_relative 'build_tools/entities/jenkins_build'
require_relative 'build_tools/operations/form_base_url'
require_relative 'build_tools/transactions/get_last_build'

require_relative 'build_tools/contracts/run_job'
require_relative 'build_tools/transactions/run_job'
require_relative 'build_tools/transactions/deploy'
