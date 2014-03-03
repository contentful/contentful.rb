# contentful.rb

Ruby client for the Contentful Delivery API.


## Setup

Add to Gemfile and bundle:

    gem 'contentful'


## Usage

    client = Contentful::Client.new(
      accessToken: 'b4c0n73n7fu1',
      space: 'cfexampleapi',
    )

[...]

### Resource


### Dynamic Entries

You can create a specialized entry class based on a ContentType:

    content_type = client.content_type 'nyancat'
    MyEntry = Contentful::DynamicEntry.new(content_type)

It is also possible to pass in the raw json string:

    MyEntry = Contentful::DynamicEntry.new(
      '{
        "name": "SomeCat",
        "displayField": "name",
        "description": "Meow.",
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
        ],
        }
      }'