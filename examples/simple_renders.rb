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
