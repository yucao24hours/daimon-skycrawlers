require "faraday"
require "daimon_skycrawlers/filter/base"

module DaimonSkycrawlers
  module Filter
    #
    # This filter provides update checker for given URL.
    #
    # Skip processing URLs that is latest (not updated since previous
    # access).
    #
    class UpdateChecker < Base
      def initialize(connection: connection, storage: nil, base_url: nil)
        super(storage: storage)
        @connection = connection
      end

      #
      # @param [String] url
      # @param connection [Faraday]
      # @return [true|false] Return true when need update, otherwise return false
      #
      def call(path, connection: nil)
        page = storage.find(absolute_url(path))
        return true unless page
        headers = @connection.head(path).headers
        case
        when headers.key?("etag") && page.etag
          headers["etag"] != page.etag
        when headers.key?("last-modified") && page.last_modified_at
          headers["last-modified"] > page.last_modified_at
        else
          true
        end
      end

      alias updated? call

      private

      def absolute_url(url)
        @connection.build_url(url)
      end
    end
  end
end
