require 'contentful'


client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: "b4c0n73n7fu1",
  dynamic_entries: :auto,
)

p happycat = client.entry('happycat') # #<Contentful::DynamicEntry[cat]:10078260 @fields={:name=>"Happy Cat" ...
p happycat.is_a? Contentful::DynamicEntry # true
p happycat.color # gray
