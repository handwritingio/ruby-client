require 'json'
require 'uri'

require 'minitest/autorun'
require 'handwritingio'

class ClientTest < Minitest::Test

  # These credentials are for a test key
  KEY = '9V46FJ4J2T7HKEY6'
  SECRET = '011WCJ8ZTFV4TATF'

  def setup
    @client = Handwritingio::Client.with_credentials(KEY, SECRET)
  end

  def test_with_credentials
    client = Handwritingio::Client.with_credentials('foo', 'bar')
    assert_equal client.uri.user, 'foo'
    assert_equal client.uri.password, 'bar'
    assert_equal client.uri.host, 'api.handwriting.io'
  end

  def test_constructor
    client = Handwritingio::Client.new('https://foo:bar@api.handwriting.io')
    assert_equal client.uri.user, 'foo'
    assert_equal client.uri.password, 'bar'
    assert_equal client.uri.host, 'api.handwriting.io'

    uri = URI.parse('https://foo:bar@api.handwriting.io') 
    client = Handwritingio::Client.new(uri)
    assert_equal client.uri.user, 'foo'
    assert_equal client.uri.password, 'bar'
    assert_equal client.uri.host, 'api.handwriting.io'
  end

  def test_handwritings
    handwritings = @client.handwritings(limit: 5, offset: 100, order_by: 'title', order_dir: 'desc')
    assert_equal handwritings.size, 5
    assert_equal handwritings.map(&:title), handwritings.map(&:title).sort.reverse
    refute_equal handwritings.first.title[0], 'A'
    refute_equal handwritings.first.title[0], 'Z'
  end

  def test_handwriting
    handwriting = @client.handwriting('5WGWVX9800WC')
    assert_equal handwriting.title, 'Cedar'
  end

end

class HandwritingTest < Minitest::Test
  def test_attributes
    raw = %|{
      "id": "2D5S46A80003",
      "title": "Perry",
      "date_created": "2016-06-10T16:20:24.251406Z",
      "date_modified": "2016-06-10T16:20:24.251406Z",
      "rating_neatness": 1338,
      "rating_cursivity": 1335,
      "rating_embellishment": 1274,
      "rating_character_width": 1515
    }|
    handwriting = Handwritingio::Handwriting.new(JSON.parse(raw))
    assert_equal handwriting.id, '2D5S46A80003'
    assert_equal handwriting.title, 'Perry'
    assert_equal handwriting.date_created.year, 2016
    assert_equal handwriting.date_created.month, 6
    assert_equal handwriting.date_created.day, 10
    assert_equal handwriting.date_modified.year, 2016
    assert_equal handwriting.date_modified.month, 6
    assert_equal handwriting.date_modified.day, 10
    assert_equal handwriting.rating_neatness, 1338
    assert_equal handwriting.rating_cursivity, 1335
    assert_equal handwriting.rating_embellishment, 1274
    assert_equal handwriting.rating_character_width, 1515
  end

  def test_initialize_many
    raw = %|[
      {
        "id": "2D5QW0F80001",
        "title": "Molly",
        "date_created": "2016-06-10T16:20:24.251406Z",
        "date_modified": "2016-06-10T16:20:24.251406Z",
        "rating_neatness": 1535,
        "rating_cursivity": 1307,
        "rating_embellishment": 1314,
        "rating_character_width": 1311
      },
      {
        "id": "2D5S18M00002",
        "title": "Winters",
        "date_created": "2016-06-10T16:20:24.251406Z",
        "date_modified": "2016-06-10T16:20:24.251406Z",
        "rating_neatness": 1425,
        "rating_cursivity": 1363,
        "rating_embellishment": 1319,
        "rating_character_width": 1227
      },
      {
        "id": "2D5S46A80003",
        "title": "Perry",
        "date_created": "2016-06-10T16:20:24.251406Z",
        "date_modified": "2016-06-10T16:20:24.251406Z",
        "rating_neatness": 1338,
        "rating_cursivity": 1335,
        "rating_embellishment": 1274,
        "rating_character_width": 1515
      },
      {
        "id": "2D5S46JG0004",
        "title": "Squire",
        "date_created": "2016-06-10T16:20:24.251406Z",
        "date_modified": "2016-06-10T16:20:24.251406Z",
        "rating_neatness": 1470,
        "rating_cursivity": 1262,
        "rating_embellishment": 1315,
        "rating_character_width": 1397
      }
    ]|
    handwritings = Handwritingio::Handwriting.initialize_many(JSON.parse(raw))
    assert_equal handwritings.map(&:title), ['Molly', 'Winters', 'Perry', 'Squire']
  end
end
