### simplecov -> start
if ENV['SIMPLECOV_ACTIVE']
  require 'simplecov'
  SimpleCov.at_exit do
    SimpleCov.result.format!

    config = {
      minimum_coverage: SimpleCov.minimum_coverage,
      maximum_coverage_drop: SimpleCov.maximum_coverage_drop,
      minimum_coverage_by_file: SimpleCov.minimum_coverage_by_file,
    }
    rspec_runner_index = ENV['TEST_ENV_NUMBER'.freeze].to_i
    STDOUT.print "\n|||NEW_MESSAGE|||RUNNING|||SIMPLECOV_CONFIG|||#{JSON.fast_generate([rspec_runner_index, config])}|||\n"
  end

  module PrependSc
    def start(*args, &block)
      add_filter "tmp"
      merge_timeout 3600
      command_name "RSpec_\#{ENV['TEST_ENV_NUMBER'.freeze].to_i}"

      if ENV['NO_COVERAGE']
        use_merging false
        return
      end
      super
    end
  end

  SimpleCov.singleton_class.prepend(PrependSc)

  module Scf
    def format!
      return if ENV['NO_COVERAGE']
      rspec_runner_index = ENV['TEST_ENV_NUMBER'.freeze].to_i

      original_result_json = JSON.fast_generate(original_result)
      compressed_data = Base64.strict_encode64(Zlib::Deflate.deflate(original_result_json, 9))
      STDOUT.print "\n|||NEW_MESSAGE|||RUNNING|||SIMPLECOV_RESULT|||#{JSON.fast_generate([rspec_runner_index, compressed_data])}|||\n"
      super
    end
  end

  SimpleCov::Result.prepend(Scf)
end
### SimpleCov -> End