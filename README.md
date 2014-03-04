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


### Notes on Resources

The response data is saved in Contentful::Resource objects. They have snake_cased method accessors, but also provide a way to access the response as hash.

#### Properties

Properties can be directly accessed, but are also all at once available in a hash called :properties

    ...

#### System Properties

System properties can be directly accessed, but are also all at once available in a hash called :sys

    content_type.id # => 'cat'
    entry.type # => 'Entry'
    asset.sys # { id: '...', type: '...' }

#### Entry Fields

Entry fields usually don't have direct method accessors, since they are based on the available content types. You can access the fields via a hash called :fields

    ...

However, you can set :entry_mode to :dynamic in your client. If using this option, the client will fetch all available content types and use them to create dynamic entries on the fly.

    client = Contentful::Client.new(
      # credentials
      entry_mode: :dynamic,
    )
    # example entry

To update your ContentType cache manually, you can call `client.update_content_types!`













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