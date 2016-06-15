# Handwriting.io Client

[![Code Climate](https://codeclimate.com/github/handwritingio/ruby-client/badges/gpa.svg)](https://codeclimate.com/github/handwritingio/ruby-client)

## Installation

```bash
gem install handwritingio
```

## Basic Example

Set up a client and list multiple pages of available handwritings:

```ruby
require 'rubygems'
require 'handwritingio'

# These credentials are for a test key
# Set up your own keys at https://www.handwriting.io
key = '9V46FJ4J2T7HKEY6'
secret = '011WCJ8ZTFV4TATF'

client = Handwritingio::Client.with_credentials(key, secret)
handwritings = []
limit = 50
offset = 0
page = client.handwritings(limit: limit, offset: offset)
page_count = 1
until page.empty?
  handwritings += page
  offset += limit
  page = client.handwritings(limit: limit, offset: offset)
  page_count += 1
end

puts "#{handwritings.count} handwritings listed in #{page_count} pages"
```

The output should look like this:

```
> ruby examples/list_all_handwritings.rb
203 handwritings listed in 6 pages
```

Set up the client, render an image, and write it to a file:

```ruby
require 'pathname'
require 'tmpdir'

require 'rubygems'
require 'handwritingio'

# These credentials are for a test key
# Set up your own keys at https://www.handwriting.io
key = '9V46FJ4J2T7HKEY6'
secret = '011WCJ8ZTFV4TATF'

thank_you = <<-eos
Dear Lauren and Steve,

  Thank you so much for the thoughtful wedding gift. We were looking at crystal wine glasses just the other week. Hope you have a good trip with the family and hope to see you when you get back!

    All the best,
    Allison and Jeremy
eos

client = Handwritingio::Client.with_credentials(key, secret)

# Dimensions here are a typical 1080p display
png = client.render_png(text: thank_you, handwriting_id: '5WGWVX9800WC', width: '1920px', height: '1080px', handwriting_size: '40px')
pathname = Pathname.new(Dir.tmpdir) + 'handwriting.png'
bytes = pathname.write(png)
puts "#{bytes} written to #{pathname}"

# Dimensions here are a typical 8 1/2 x 11 inch sheet of paper
pdf = client.render_pdf(text: thank_you, handwriting_id: '5WGWVX9800WC', width: '8.5in', height: '11in', handwriting_size: '24pt')
pathname = Pathname.new(Dir.tmpdir) + 'handwriting.pdf'
bytes = pathname.write(pdf)
puts "#{bytes} written to #{pathname}"
```

The output should look like this:
```
> ruby examples/simple_renders.rb
103262 written to /tmp/handwriting.png
643577 written to /tmp/handwriting.pdf
```

The images written should look like these:

[handwriting.png](https://s3.amazonaws.com/hwio-cdn-production/ruby-client/handwriting.png)

[handwriting.pdf](https://s3.amazonaws.com/hwio-cdn-production/ruby-client/handwriting.pdf)

## Advanced Example with RMagick

```ruby
require 'pathname'
require 'tmpdir'

require 'rubygems'
require 'handwritingio'
require 'rmagick'

# These credentials are for a test key
# Set up your own keys at https://www.handwriting.io
key = '9V46FJ4J2T7HKEY6'
secret = '011WCJ8ZTFV4TATF'

thank_you = <<-eos
Dear Lauren and Steve,

  Thank you so much for the thoughtful wedding gift. We were looking at crystal wine glasses just the other week. Hope you have a good trip with the family and hope to see you when you get back!

    All the best,
    Allison and Jeremy
eos

client = Handwritingio::Client.with_credentials(key, secret)

# Dimensions here are a typical 1080p display
png = client.render_png(
  text: thank_you,
  handwriting_id: '5WGWVX9800WC',
  width: '1920px',
  height: '1080px',
  handwriting_size: '60px',
  random_seed: 42)

image = Magick::Image.from_blob(png).first
pathname = Pathname.new(Dir.tmpdir) + 'rmagick.png'

light_shadow = image.shadow(4, 4, 4.0, 0.7)
dark_shadow = light_shadow.solarize(25) # Drop shadow
light_shadow.destroy!
composite = dark_shadow.composite(image, 0, 0, Magick::OverCompositeOp)
dark_shadow.destroy!
image.destroy!

composite.border!(1, 1, "#FFFFFF") # Prevents smear at edges during distort
distorted = composite.distort(Magick::ArcDistortion, [30])
composite.destroy!
distorted.scale!(1920, 1080) # scale back to desired dimensions
distorted.write(pathname)
distorted.destroy!
puts "image written to #{pathname}"
```

It should create an image like this : [rmagick.png](https://s3.amazonaws.com/hwio-cdn-production/ruby-client/rmagick.png)

## Reference

See the [API Documentation](https://www.handwriting.io/docs) for details on all endpoints and parameters. For the most part, the Client passes parameters through to the API directly.

The endpoints map to client methods as follows:

- [GET /handwritings](https://handwriting.io/docs/#get-handwritings) -> `Client#handwritings(params)`
- [GET /handwritings/{id}](https://handwriting.io/docs/#get-handwritings--id-) -> `Client#handwriting(handwriting_id)`
- [GET /render/png](https://handwriting.io/docs/#get-render-png) -> `Client#render_png(params)`
- [GET /render/pdf](https://handwriting.io/docs/#get-render-pdf) -> `Client#render_pdf(params)`

## Version Numbers

Version numbers for this package work slightly differently than standard
[semantic versioning](http://semver.org/). For this package, the `major`
version number will match the Handwriting.io API version number, and the
`minor` version will be  incremented for any breaking changes to this package.
The `patch` version will be incremented for bug fixes and changes that add
functionality only.

## Issues

Please open an issue on [Github](https://github.com/handwritingio/ruby-client/issues)
or [contact us](https://handwriting.io/contact) directly for help with any
problems you find.
