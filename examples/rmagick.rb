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
