require "test_helper"
require "daimon_skycrawlers/filter/update_checker"
require "pry"

class DaimonSkycrawlersUpdateCheckerTest < Test::Unit::TestCase
  setup do
    @storage = DaimonSkycrawlers::Storage::RDB.new(fixture_path("database.yml"))
    load(fixture_path("schema.rb"))
    @base_url = "http://example.com"
    @path = "/blog/2016/1.html"
    @url = @base_url + @path

  end

  def create_target(response = [200, {}, ''])
    connection = Faraday.new(url: @base_url) do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.head(@path){|env| response }
      end
    end

    filter = DaimonSkycrawlers::Filter::UpdateChecker.new(connection: connection)
    mock(filter).storage { @storage }

    filter
  end

  test "url does not exist in storage" do
    mock(@storage).find(@url) { nil }
    filter = create_target
    assert_true(filter.call(@path))
  end

  sub_test_case "url exist in storage" do
    test "need update when no etag and no last-modified" do
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url) }

      response = [200, { "last-modified" => "Sun, 31 Aug 2008 12:34:56 GMT" }, '']
      filter = create_target(response)

      assert_true(filter.call(@path))
    end

#    test "need update when last-modified is newer than page.last_modified_at" do
#      now = Time.now
#      page = DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, last_modified_at: Time.at(now - 1))
#      # ここらへんのモックで head の戻り値をハッシュにしてるのがいけない
#      stubs = Faraday::Adapter::Test::Stubs.new
#      test = Faraday.new do |builder|
#        builder.adapter :test, stubs do |stub|
#          stub.head(@url){|env| [200, { "last-modified" => now }, ''] }
#        end
#      end
#      mock(Faraday).head(@url) { test.head(@url) }
#      mock(@storage).find(@url) { page }
#      assert_true(@filter.call(@url))
#    end
#
#    test "not need update when last-modified is older than page.last_modified_at" do
#      now = Time.now
#      page = DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, last_modified_at: Time.at(now - 1))
#      # ここらへんのモックで head の戻り値をハッシュにしてるのがいけない
#      stubs = Faraday::Adapter::Test::Stubs.new
#      test = Faraday.new do |builder|
#        builder.adapter :test, stubs do |stub|
#          stub.head(@url){|env| [200, { "last-modified" => Time.at(now - 2) }, ''] }
#        end
#      end
#      mock(Faraday).head(@url) { test.head(@url) }
#      mock(@storage).find(@url) { page }
#      assert_false(@filter.call(@url))
#    end
#
#    test "etag matches" do
#      page = DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, etag: "xxxxx")
#      # ここらへんのモックで head の戻り値をハッシュにしてるのがいけない
#      stubs = Faraday::Adapter::Test::Stubs.new
#      test = Faraday.new do |builder|
#        builder.adapter :test, stubs do |stub|
#          stub.head(@url){|env| [200, { "etag" => "xxxxx" }, ''] }
#        end
#      end
#      mock(Faraday).head(@url) { test.head(@url) }
#      mock(@storage).find(@url) { page }
#      assert_false(@filter.call(@url))
#    end
#
#    test "need update when etag does not match" do
#      now = Time.now
#      page = DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, etag: "xxxxx", last_modified_at: now)
#      # ここらへんのモックで head の戻り値をハッシュにしてるのがいけない
#      stubs = Faraday::Adapter::Test::Stubs.new
#      test = Faraday.new do |builder|
#        builder.adapter :test, stubs do |stub|
#          stub.head(@url){|env| [200, { "etag" => "yyyyy", "last-modified" => Time.at(now + 1) }, ''] }
#        end
#      end
#      mock(Faraday).head(@url) { test.head(@url) }
#      mock(@storage).find(@url) { page }
#      assert_true(@filter.call(@url))
#    end
#
#    test "need update with relative path w/o headers" do
#      page = DaimonSkycrawlers::Storage::RDB::Page.new(url: @url)
#      # ここらへんのモックで head の戻り値をハッシュにしてるのがいけない
#      stubs = Faraday::Adapter::Test::Stubs.new
#      test = Faraday.new do |builder|
#        builder.adapter :test, stubs do |stub|
#          stub.head(@url){|env| [200, {}, ''] }
#        end
#      end
#      mock(Faraday).head(@url) { test.head(@url) }
#      mock(@storage).find(@url) { page }
#      assert_true(@filter.call("./2016/1.html"))
#    end
  end
end
