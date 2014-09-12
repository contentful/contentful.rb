require 'contentful'

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
)

p client.space

p client.content_types

p client.entry 'nyancat', locale: 'tlh'

p client.entries(
  'content_type' => 'cat',
  'fields.likes' => 'lasagna',
)

p client.entries(
   query: 'bacon',
)

p client.content_types(
  order: '-sys.updatedAt',
  limit: 3,
)
