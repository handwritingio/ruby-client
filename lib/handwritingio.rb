require 'uri'
require 'net/http'
require 'json'
require 'time'
require 'forwardable'

module Handwritingio
  class Client
    attr_reader :uri

    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    end

    def handwriting(id)
      Handwriting.new(JSON.parse(get("/handwritings/#{id}")))
    end

    def handwritings(params = {})
      Handwriting.initialize_many(JSON.parse(get("/handwritings", params)))
    end

    def render_png(params)
      get("/render/png", params)
    end

    def render_pdf(params)
      get("/render/pdf", params)
    end

    def get(path, params = {})
      uri = @uri
      uri.path = path

      unless params.empty?
        uri.query = URI.encode_www_form(params)
      end

      req = Net::HTTP::Get.new(uri)
      req.basic_auth(uri.user, uri.password)

      use_ssl = uri.scheme == 'https'
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) {|http|
        http.request(req)
      }

      if res.is_a?(Net::HTTPSuccess)
        return res.body
      else
        raise Errors.new(res)
      end
    end
    private :get

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

    def self.initialize_many(hashes)
      hashes.map{ |hash| new(hash) }
    end

  end

  class Errors < RuntimeError
    extend Forwardable
    def_delegators :@parsed, :[], :count, :map, :each, :first, :last

    attr_reader :response

    def initialize(response)
      @response = response
      @parsed = JSON.parse(response.body)['errors'].map{ |e| Error.new(e) }
    end

    def inspect
      "#<#{self.class.name} (#{self.count})>"
    end

  end

  class Error < RuntimeError
    attr_reader :error

    def initialize(hash)
      @error = hash['error']
    end

    def inspect
      "#<#{self.class.name} #{self.error.inspect}>"
    end

  end

end
