# frozen_string_literal: true

module BuildTools
  module Transactions
    class Deploy
      include Transaction

      TIMEOUT_SECONDS = 2700 # 45 mins for good measure
      POLL_INTERVAL = 5
      JOB = 'deploy'

      def initialize(deps = {})
        __get_last_build = GetLastBuild.new
        @build_function = deps[:build_function] || lambda do |env, job|
          lambda do
            __get_last_build.call(env: env, job: JOB)
          end
        end
        @run_job = deps[:run_job] || RunJob.new
      end

      def call(env:, branch:)
        get_last_build = @build_function.call(env, JOB)
        last_build = yield get_last_build.call

        Timeout::timeout(TIMEOUT_SECONDS) do
          until last_build.no_longer_running? do
            sleep(POLL_INTERVAL)
            last_build = yield get_last_build.call
          end

          job_params = build_params(env, branch)
          yield @run_job.call(env: env, job: JOB, params: job_params)

          current_build = yield get_last_build.call

          until current_build_finished?(current_build, last_build)
            sleep(POLL_INTERVAL)
            current_build = yield get_last_build.call
          end

          if current_build.success?
            Success(:ok)
          else
            Failure(current_build.result)
          end
        end
      rescue Timeout::Error
        Failure(timeout: "job did not finish within #{TIMEOUT_SECONDS} seconds")
      end

      private

      def current_build_finished?(current_build, last_build)
        current_build.id > last_build.id && current_build.no_longer_running?
      end

      def build_params(env, branch)
        { token: ENV['JENKINS_JOB_TOKEN'], env: env, branch: branch }
      end
    end
  end
end
