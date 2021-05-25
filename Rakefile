# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

$LOAD_PATH.unshift File.expand_path("./lib", __dir__)
require 'build_tools'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

namespace :jenkins do
  desc 'Deploy to Jenkins'
  task :deploy, [:env,:branch] do |t, args|
    deploy = BuildTools::Transactions::Deploy.new

    result = deploy.call(env: args.env, branch: args.branch)

    if result.success?
      puts result.success
    else
      raise BuildTools::Error.new(result.failure)
    end
  end
end
