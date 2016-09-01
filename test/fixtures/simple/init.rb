require "daimon_skycrawlers"
require "daimon_skycrawlers/logger"
require "daimon_skycrawlers/queue"

DaimonSkycrawlers.configure do |config|
  config.shutdown_interval = 5
end
