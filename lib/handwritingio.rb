require 'uri'
require 'net/http'
require 'json'
require 'time'

module Handwritingio
  class Client
    attr_reader :uri

    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    end

    def handwriting(id)
      uri = @uri
      uri.path = "/handwritings/#{id}"
      req = Net::HTTP::Get.new(uri)
      req.basic_auth(uri.user, uri.password)

      use_ssl = uri.scheme == 'https'
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) {|http|
        http.request(req)
      }
      Handwriting.new(JSON.parse(res.body))
    end

    DEFAULT_URI = URI.parse('https://api.handwriting.io')

    def self.with_credentials(key, secret)
      uri = DEFAULT_URI
      uri.user = key
      uri.password = secret
      new(uri)
    end

  end

  class Handwriting
    attr_reader :id, :title, :date_created, :date_modified, :rating_neatness, :rating_cursivity, :rating_embellishment, :rating_character_width
    alias :created_at :date_created
    alias :updated_at :date_modified

    def initialize(hash)
      @id = hash['id']
      @title = hash['title']
      @date_created = DateTime.parse(hash['date_created'])
      @date_modified = DateTime.parse(hash['date_modified'])
      @rating_neatness = hash['rating_neatness']
      @rating_cursivity = hash['rating_cursivity']
      @rating_embellishment = hash['rating_embellishment']
      @rating_character_width = hash['rating_character_width']
    end

    def inspect
      "#<#{self.class.name} id=#{@id.inspect} title=#{@title.inspect}>"
    end

  end
end