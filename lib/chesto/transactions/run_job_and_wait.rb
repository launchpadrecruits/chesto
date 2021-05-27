# frozen_string_literal: true

module Chesto
  module Transactions
    class RunJobAndWait
      include Transaction

      TIMEOUT_SECONDS = 2700 # 45 mins for good measure
      POLL_INTERVAL = 5

      def initialize(deps = {})
        __get_last_build = GetLastBuild.new
        @build_function = deps[:build_function] || lambda do |job|
          lambda do
            __get_last_build.call(job)
          end
        end
        @run_job = deps[:run_job] || RunJob.new
      end

      def call(job:, params:)
        get_last_build = @build_function.call(job)
        last_build = yield get_last_build.call

        Timeout::timeout(TIMEOUT_SECONDS) do
          until last_build.no_longer_running? do
            sleep(POLL_INTERVAL)
            last_build = yield get_last_build.call
          end

          yield @run_job.call(job: job, params: params)

          current_build = yield get_last_build.call
          until current_build_finished?(current_build, last_build)
            sleep(POLL_INTERVAL)
            current_build = yield get_last_build.call
          end

          if current_build.success?
            Success(current_build)
          else
            Failure(current_build)
          end
        end
      rescue Timeout::Error
        Failure(timeout: "job did not finish within #{TIMEOUT_SECONDS} seconds")
      end

      private

      def current_build_finished?(current_build, last_build)
        current_build.id > last_build.id && current_build.no_longer_running?
      end
    end
  end
end
