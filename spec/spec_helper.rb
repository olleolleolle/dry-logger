# frozen_string_literal: true

require "pathname"
require "fileutils"
require "securerandom"

SPEC_ROOT = Pathname(__FILE__).dirname

RELATIVE_TMP = File.join(".", "tmp")
FileUtils.mkdir_p(RELATIVE_TMP)

TMP = SPEC_ROOT.join("..", RELATIVE_TMP).realpath

if RUBY_ENGINE == "ruby" && ENV["COVERAGE"] == "true"
  require "yaml"
  rubies = YAML.safe_load(File.read(SPEC_ROOT.join("../.travis.yml")))["rvm"]
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION >= latest_mri
    require "simplecov"

    SimpleCov.start do
      add_filter "/spec/"
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?
  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end

require "dry/logger"

require "pathname"
Dir.glob(Pathname.new(__dir__).join("support", "**", "*.rb")).each do |file|
  require_relative file
end
