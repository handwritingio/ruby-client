require 'uri'
require 'net/http'
require 'json'
require 'time'
require 'forwardable'

##
# Contains Client and supporting classes for interacting with Handwriting.io API
module Handwritingio

  ##
  # The Official Handwriting.io API Client
  class Client
    attr_reader :uri

    ##
    # Creates a new +Client+ given a complete uri.
    #
    # Prefer Client.with_credentials unless you to control hostname.
    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    end

    ##
    # Get a handwriting
    #
    # Parameters
    # [id]
    #   Handwriting ID
    #   required
    def handwriting(id)
      Handwriting.new(JSON.parse(get("/handwritings/#{id}")))
    end

    ##
    # Lists handwritings
    #
    # Parameters
    # [limit]
    #   number of items to fetch
    #   defaults to 200, minimum is 1, maximum is 1000
    # [offset]
    #   starting point in data set
    #   defaults to 0
    # [order_dir]
    #   order direction
    #   defaults to asc, value must be one of: asc, desc
    # [order_by]
    #   order field
    #   defaults to id, value must be one of: id, title, date_created, date_modified, rating_neatness, rating_cursivity, rating_embellishment, rating_character_width
    def handwritings(params = {})
      Handwriting.initialize_many(JSON.parse(get("/handwritings", params)))
    end

    ##
    # Render text in the specified handwriting, as a PNG image.
    # 
    # Parameters
    # 
    # [handwriting_id]
    #   +required+
    #   The ID of the handwriting to use.
    # [text]
    #   +required+
    #   maximum length is 9000 characters
    # [handwriting_size] 
    #   The size of the handwriting, from baseline to cap height.
    #   defaults to 20px, minimum is 0px, maximum is 9000px
    # [handwriting_color] 
    #   The color of the handwriting expressed as #RRGGBB.
    #   defaults to #000000
    # [width] 
    #   Width of the image.
    #   defaults to 504px, minimum is 0px, maximum is 9000px
    # [height] 
    #   Height of the image. May be set to `auto` to determine the height automatically based on the text.
    #   defaults to 360px, minimum is 0px, maximum is 9000px
    # [min_padding] 
    #   +experimental+
    #   Centers the block of text within the image, preserving at least min_padding around all four edges of the image.
    # [line_spacing] 
    #   Amount of vertical space for each line, provided as a multiplier of handwriting_size.
    #   defaults to 1.5, minimum is 0.0, maximum is 5.0
    # [line_spacing_variance] 
    #   Amount to randomize spacing between lines, provided as a multiplier. Example: 0.1 means the space between lines will vary by +/- 10%.
    #   defaults to 0.0, minimum is 0.0, maximum is 1.0
    # [word_spacing_variance] 
    #   Amount to randomize spacing between words, provided as a multiplier. Example: 0.1 means the space between words will vary by +/- 10%.
    #   defaults to 0.0, minimum is 0.0, maximum is 1.0
    # [random_seed] 
    #   Set this to a positive number to get a repeatable image. If this parameter is included and positive, the returned image should always be the same for the given set of parameters.
    #   defaults to -1
    def render_png(params)
      get("/render/png", params)
    end

    # Render text in the specified handwriting as a PDF file.
    # 
    # Parameters
    # 
    # [handwriting_id]
    #   +required+
    #   The ID of the handwriting to use.
    # [text]
    #   +required+
    #   maximum length is 9000 characters
    # [handwriting_size]
    #   The size of the handwriting, from baseline to cap height.
    #   defaults to 20pt, minimum is 0in, maximum is 100in
    # [handwriting_color]
    #   The color of the handwriting expressed as (C,M,Y,K).
    #   defaults to (0, 0, 0, 1)
    # [width]
    #   Width of the image.
    #   defaults to 7in, minimum is 0in, maximum is 100in
    # [height]
    #   Height of the image. May be set to auto to determine the height automatically based on the text.
    #   defaults to 5in, minimum is 0in, maximum is 100in
    # [min_padding]
    #   +experimental+
    #   Centers the block of text within the image, preserving at least min_padding around all four edges of the image.
    # [line_spacing]
    #   Amount of vertical space for each line, provided as a multiplier of handwriting_size.
    #   defaults to 1.5, minimum is 0.0, maximum is 5.0
    # [line_spacing_variance]
    #   Amount to randomize spacing between lines, provided as a multiplier. Example: 0.1 means the space between lines will vary by +/- 10%.
    #   defaults to 0.0, minimum is 0.0, maximum is 1.0
    # [word_spacing_variance]
    #   Amount to randomize spacing between words, provided as a multiplier. Example: 0.1 means the space between words will vary by +/- 10%.
    #   defaults to 0.0, minimum is 0.0, maximum is 1.0
    # [random_seed]
    #   Set this to a positive number to get a repeatable image. If this parameter is included and positive, the returned image should always be the same for the given set of parameters.
    #   defaults to -1
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

    ##
    # Production API URI
    DEFAULT_URI = URI.parse('https://api.handwriting.io')

    ##
    # Initializes a new Client with just your key and secret.
    #
    # This will be the most common way to get a Client instance.
    # If you need more control use Client.new.
    def self.with_credentials(key, secret)
      uri = DEFAULT_URI
      uri.user = key
      uri.password = secret
      new(uri)
    end

  end

  ##
  # Handwriting class returned from Client#handwritings and Client#handwriting
  class Handwriting
    attr_reader :id, :title, :date_created, :date_modified, :rating_neatness, :rating_cursivity, :rating_embellishment, :rating_character_width
    def initialize(hash) #:nodoc:
      @id = hash['id']
      @title = hash['title']
      @date_created = DateTime.parse(hash['date_created'])
      @date_modified = DateTime.parse(hash['date_modified'])
      @rating_neatness = hash['rating_neatness']
      @rating_cursivity = hash['rating_cursivity']
      @rating_embellishment = hash['rating_embellishment']
      @rating_character_width = hash['rating_character_width']
    end

    def inspect #:nodoc:
      "#<#{self.class.name} id=#{@id.inspect} title=#{@title.inspect}>"
    end

    def self.initialize_many(hashes) #:nodoc:
      hashes.map{ |hash| new(hash) }
    end

  end

  ##
  # +Errors+ class for errors raised by the API
  #
  # Contains one or more +Error+
  class Errors < RuntimeError
    extend Forwardable
    def_delegators :@parsed, :[], :count, :map, :each, :first, :last

    attr_reader :response

    def initialize(response) #:nodoc:
      @response = response
      @parsed = JSON.parse(response.body)['errors'].map{ |e| Error.new(e) }
    end

    def inspect #:nodoc:
      "#<#{self.class.name} (#{self.count})>"
    end

  end

  ##
  # Error class for individual error descriptions
  class Error < RuntimeError
    attr_reader :error, :field

    def initialize(hash) #:nodoc:
      @error = hash['error']
      @field = hash['field']
    end

    def inspect #:nodoc:
      "#<#{self.class.name} #{self.error.inspect}>"
    end

  end

end
