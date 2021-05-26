# frozen_string_literal: true

module BuildTools
  module Operations
    class FormBaseUrl
      include Operation
      include Singleton

      def call(job)
        if STRING_PRESENT.call(ENV['JENKINS_URL']) && STRING_PRESENT.call(ENV['JENKINS_JOB_PATH'])
          Success("#{ENV['JENKINS_URL']}/#{ENV['JENKINS_JOB_PATH']}/#{job}")
        else
          Failure(env: 'jenkins url or job path not supplied')
        end
      end
    end
  end
end
