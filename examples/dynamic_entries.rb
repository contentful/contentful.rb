require 'contentful'

# A DynamicEntry is a resource classes, specifically for one ContentType
# This is the manual way of creating a dynamic class. This should not be
# neceassary in :auto mode

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  dynamic_entries: :manual,
)

cat = client.content_type('cat')
CatEntry = Contentful::DynamicEntry.create(cat)
client.register_dynamic_entry 'cat', CatEntry

# The CatEntry behaves just like a normal entry, but it has knowlegde about the entry fields.
# It will create getter methods and convert field contents to the proper type:

nyancat = client.entry('nyancat')
p nyancat.is_a? CatEntry # => true
p nyancat.fields[:name] # => "Nyan Cat" # This would also be possible with a non-dynamic entry
p nyancat.name # => "Nyan Cat"

# You don't need to initialize a ContentType resource to create a DynamicEntry
# You could also pass the content type's JSON representation:

SuperCatEntry = Contentful::DynamicEntry.create <<JSON
{
  "fields": [
    {
      "id": "name",
      "name": "Name",
      "type": "Text",
      "required": true,
      "localized": true
    },
    {
      "id": "likes",
      "name": "Likes",
      "type": "Array",
      "required": false,
      "localized": false,
      "items": {
        "type": "Symbol"
      }
    },
    {
      "id": "color",
      "name": "Color",
      "type": "Symbol",
      "required": false,
      "localized": false
    },
    {
      "id": "bestFriend",
      "name": "Best Friend",
      "type": "Link",
      "required": false,
      "localized": false,
      "linkType": "Entry"
    },
    {
      "id": "birthday",
      "name": "Birthday",
      "type": "Date",
      "required": false,
      "localized": false
    },
    {
      "id": "lifes",
      "name": "Lifes left",
      "type": "Integer",
      "required": false,
      "localized": false,
      "disabled": true
    },
    {
      "id": "lives",
      "name": "Lives left",
      "type": "Integer",
      "required": false,
      "localized": false
    },
    {
      "id": "image",
      "name": "Image",
      "required": false,
      "localized": false,
      "type": "Link",
      "linkType": "Asset"
    }
  ],
  "name": "Cat",
  "displayField": "name",
  "description": "Meow.",
  "sys": {
    "space": {
      "sys": {
        "type": "Link",
        "linkType": "Space",
        "id": "cfexampleapi"
      }
    },
    "type": "ContentType",
    "id": "cat",
    "revision": 2,
    "createdAt": "2013-06-27T22:46:12.852Z",
    "updatedAt": "2013-09-02T13:14:47.863Z"
  }
}
JSON

# AUTO MODE - All entries will be converted to dynamic entries

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  dynamic_entries: :auto,
)

p happycat = client.entry('happycat') # #<Contentful::DynamicEntry[cat]:10078260 @fields={:name=>"Happy Cat" ...
p happycat.is_a? Contentful::DynamicEntry # true
p happycat.color # gray
