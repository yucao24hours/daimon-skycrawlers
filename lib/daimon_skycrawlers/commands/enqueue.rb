require "daimon_skycrawlers"
require "daimon_skycrawlers/crawler"
require "daimon_skycrawlers/processor"

module DaimonSkycrawlers
  module Commands
    class Enqueue < Thor
      desc "url URL [key1:value1 key2:value2...]", "Enqueue URL for URL consumer"
      def url(url, *rest)
        message = rest.map {|arg| arg.split(":") }.to_h
        DaimonSkycrawlers::Crawler.enqueue_url(url, message)
      end

      desc "response URL [key1:value1 key2:value2...]", "Enqueue URL for HTTP response consumer"
      def response(url, *rest)
        message = rest.map {|arg| arg.split(":") }.to_h
        DaimonSkycrawlers::Processor.enqueue_http_response(url, message)
      end
    end
  end
end
