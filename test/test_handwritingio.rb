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
    assert_equal 'foo', client.uri.user
    assert_equal 'bar', client.uri.password
    assert_equal 'api.handwriting.io', client.uri.host
  end

  def test_constructor
    client = Handwritingio::Client.new('https://foo:bar@api.handwriting.io')
    assert_equal 'foo', client.uri.user
    assert_equal 'bar', client.uri.password
    assert_equal 'api.handwriting.io', client.uri.host

    uri = URI.parse('https://foo:bar@api.handwriting.io') 
    client = Handwritingio::Client.new(uri)
    assert_equal 'foo', client.uri.user
    assert_equal 'bar', client.uri.password
    assert_equal 'api.handwriting.io', client.uri.host
  end

  def test_handwritings
    handwritings = @client.handwritings(limit: 5, offset: 100, order_by: 'title', order_dir: 'desc')
    assert_equal 5, handwritings.size
    assert_equal handwritings.map(&:title).sort.reverse, handwritings.map(&:title)
    refute_equal 'A', handwritings.first.title[0]
    refute_equal 'Z', handwritings.first.title[0]
  end

  def test_handwriting
    handwriting = @client.handwriting('5WGWVX9800WC')
    assert_equal 'Cedar', handwriting.title
  end

  def test_render_png
    png = @client.render_png(text: "Hello World!", handwriting_id: '5WGWVX9800WC')
    assert_match(/^?PNG/, png)
  end

  def test_render_pdf
    pdf = @client.render_pdf(text: "Hello World!", handwriting_id: '5WGWVX9800WC')
    assert_match(/^%PDF/, pdf)
  end

  def test_failed_auth
    client = Handwritingio::Client.with_credentials(KEY, SECRET.reverse)

    errors = assert_raises(Handwritingio::Errors) do
      client.handwritings
    end
    assert_equal "unauthorized", errors.first.error
  end

  def test_failed_validation
    errors = assert_raises(Handwritingio::Errors) do
      @client.render_png(text: "Oh I needed a handwriting_id")
    end
    assert_equal 1, errors.count
    assert_equal "handwriting_id is required", errors.first.error
    assert_equal "handwriting_id", errors.first.field
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
    assert_equal '2D5S46A80003', handwriting.id
    assert_equal 'Perry', handwriting.title
    assert_equal 2016, handwriting.date_created.year
    assert_equal 6, handwriting.date_created.month
    assert_equal 10, handwriting.date_created.day
    assert_equal 2016, handwriting.date_modified.year
    assert_equal 6, handwriting.date_modified.month
    assert_equal 10, handwriting.date_modified.day
    assert_equal 1338, handwriting.rating_neatness
    assert_equal 1335, handwriting.rating_cursivity
    assert_equal 1274, handwriting.rating_embellishment
    assert_equal 1515, handwriting.rating_character_width
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
    assert_equal ['Molly', 'Winters', 'Perry', 'Squire'], handwritings.map(&:title)
  end
end
