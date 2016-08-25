require "songkick_queue"
require "daimon_skycrawlers/consumer/base"
require "daimon_skycrawlers/processor/default"

module DaimonSkycrawlers
  module Consumer
    class HTTPResponse < Base
      include SongkickQueue::Consumer

      consume_from_queue "daimon-skycrawler.http-response"

      class << self
        def register(processor = nil, &block)
          if block_given?
            processors << block
          else
            processors << processor
          end
        end

        def processors
          @processors ||= []
        end

        def default_processor
          DaimonSkycrawlers::Processor::Default.new
        end
      end

      def process(message)
        if self.class.processors.empty?
          processors = [self.class.default_processor]
        else
          processors = self.class.processors
        end
        processors.each do |processor|
          processor.call(message)
        end
      end
    end
  end
end