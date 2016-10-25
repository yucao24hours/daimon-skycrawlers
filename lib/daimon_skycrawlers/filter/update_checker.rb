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
      def initialize(connection:, storage: nil)
        super(storage: storage)
        @connection = connection
      end

      #
      # @param [String] url
      # @return [true|false] Return true when need update, otherwise return false
      #
      def call(path)
        page = storage.find(absolute_url(path))
        return true unless page
        headers = @connection.head(path).headers
        if headers.key?("etag")
          headers["etag"] != page.etag
        elsif headers.key?("last-modified")
          DateTime.httpdate(headers["last-modified"]) != page.last_modified_at
        else
          true
        end
      end

      alias updated? call

      private

      def absolute_url(url)
        @connection.build_url(url).to_s
      end
    end
  end
end
