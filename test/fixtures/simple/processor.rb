require "bundler/setup"
require "daimon_skycrawlers/processor"
require "daimon_skycrawlers/processor/default"

require_relative "./init"

DaimonSkycrawlers.register_processor do |data|
  p "It works with '#{data[:url]}'"
end

DaimonSkycrawlers.register_processor(DaimonSkycrawlers::Processor::Default.new)

DaimonSkycrawlers::Processor.run
