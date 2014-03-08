# contentful.rb

Ruby client for the [Contentful](https://www.contentful.com) Content Delivery API.


## Setup

Add to your Gemfile and bundle:

    gem 'contentful'


## Usage

    client = Contentful::Client.new(
      access_token: 'b4c0n73n7fu1',
      space: 'cfexampleapi',
    )

You can query for entries, assets, etc. very similar as described in the
[Delivery API Documentation](https://www.contentful.com/developers/documentation/content-delivery-api/). Please note, that all methods of the Ruby client library are snake_cased, instead of JavaScript's camelCase:

    # ...

You can pass many different query options:

    # ...


The results are returned as Contentful::Resource objects. You can access the resource's properties via Ruby methods or access all properties at once as a hash:

    # ...


System Properties behave in the same way. However they are stored in `@sys`:

    content_type.id # => 'cat'
    entry.type # => 'Entry'
    asset.sys # { id: '...', type: '...' }



Entry Fields usually don't have direct method accessors, since they are based on individual content types. You can access the fields via a hash called `@fields`:

    # ...


However, you can set `:dynamic_entries` to `:auto` in your client configuration (see below). If using this option, the client will fetch all available content types and use them to create dynamic entries on the fly.

    client = Contentful::Client.new(
      access_token: 'b4c0n73n7fu1',
      space: 'cfexampleapi',
      dynamic_entries: :auto,
    )
    # ... example entry

The previous example fetches all content_types on initialization. If you want to do it by hand, you will need to set the option to `:manual` and call `client.update_dynamic_entry_cache!` to fetch all content types.


## Configuration Options
### :space

Required option. The name of the space you want to access.

### :access_token

Required option. The space's secret token.

### :secure

Whether to use https. Defaults to `true`.

### :authentication_mechanism

How to authenticate with the API. Supports `:header` (default) or `:query_string`.

### :raise_errors

If set to `true` (default), error responses will be raised. If set to `false`, the error objects will simply be returned.

### :dynamic_entries

`false`, `:auto` or `:manual`. See resource description above for details on usage.

### :raw_mode

Defaults to `false`. If enabled, the API responses will not be parsed to resource objects. Might be useful for debugging.


## Advanced
### Dynamic Entries

In `:dynamic_entries` mode (see above), all entries are returned as specialized entry classes. However, you can also create these specialized classes by yourself, based on a content_type:

    content_type = client.content_type 'nyancat'
    MyEntry = Contentful::DynamicEntry.create(content_type)

It is also possible to pass in the raw content_type json string, as returned from the api.

## License

Jan Lelis - Contentful. MIT license.
