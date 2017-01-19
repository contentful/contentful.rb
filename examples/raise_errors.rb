require 'contentful'

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
)

begin
  p client.asset 'not found'
rescue => error
  p error
end

client2 = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  raise_errors: false,
)

p client2.asset 'not found'
