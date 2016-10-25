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

  def create_target(headers = {}, status_code: 200)
    connection = Faraday.new(url: @base_url) do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.head(@path){|env| [status_code, headers, ""] }
      end
    end

    DaimonSkycrawlers::Filter::UpdateChecker.new(connection: connection, storage: @storage)
  end

  test "url does not exist in storage" do
    mock(@storage).find(@url) { nil }
    filter = create_target("last-modified" => "Sun, 31 Aug 2008 12:34:56 GMT")

    assert_true(filter.call(@path))
  end

  sub_test_case "url exist in storage" do
    test "need update when no etag and no last-modified" do
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url) }
      filter = create_target("last-modified" => "Sun, 31 Aug 2008 12:34:56 GMT")

      assert_true(filter.call(@path))
    end

    test "need update when last-modified is newer than page.last_modified_at" do
      last_modified = "Sun, 31 Aug 2008 12:34:56 GMT"
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, last_modified_at: Time.at(DateTime.httpdate(last_modified) - 1)) }
      filter = create_target("last-modified" => last_modified)

      assert_true(filter.call(@path))
    end

    # XXX 実装を、 > から != にしたので、とってきたリソースがストレージ内のものより古くなっていたら？というのを考える
    test "need update when last-modified is older than page.last_modified_at" do
      last_modified = "Sun, 31 Aug 2008 12:34:56 GMT"
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, last_modified_at: Time.at(DateTime.httpdate(last_modified) + 1)) }
      filter = create_target("last-modified" => last_modified)

      assert_true(filter.call(@path))
    end

    test "etag matches" do
      last_modified = "Sun, 31 Aug 2008 12:34:56 GMT"
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, etag: "xxxxx") }
      filter = create_target("last-modified" => last_modified, "etag" => "xxxxx")

      assert_false(filter.call(@path))
    end

    test "need update when etag does not match" do
      last_modified = "Sun, 31 Aug 2008 12:34:56 GMT"
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url, etag: "xxxxx") }
      filter = create_target("last-modified" => last_modified, "etag" => "yyyyy")

      assert_true(filter.call(@path))
    end

    test "need update with relative path w/o headers" do
      mock(@storage).find(@url) { DaimonSkycrawlers::Storage::RDB::Page.new(url: @url) }
      filter = create_target

      assert_true(filter.call(@path))
    end
  end
end
