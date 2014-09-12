require 'contentful'

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  raw_mode: true,
)

entry = client.entry 'nyancat'
p entry.is_a? Contentful::Resource # false
p entry.is_a? Contentful::Response # true
p entry.status
p entry
puts entry.raw
