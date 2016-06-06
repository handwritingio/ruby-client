require './lib/handwritingio.rb'
puts "Hello Ruby!"

# TODO: Make a proper test suite
# TODO: RDoc
# TODO: Publish Gem
key = '9V46FJ4J2T7HKEY6'
secret = '011WCJ8ZTFV4TATF'
handwriting_id = '5WGWVX9800WC'

client = Handwritingio::Client.with_credentials(key, secret)
handwriting = client.handwriting(handwriting_id)
puts handwriting.created_at
