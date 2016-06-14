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
