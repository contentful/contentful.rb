# contentful.rb
[![Gem Version](https://badge.fury.io/rb/contentful.png)](http://badge.fury.io/rb/contentful) [![Build Status](https://travis-ci.org/contentful/contentful.rb.png)](https://travis-ci.org/contentful/contentful.rb) [![Coverage Status](https://coveralls.io/repos/contentful/contentful.rb/badge.png?branch=master)](https://coveralls.io/r/contentful/contentful.rb?branch=master)

Ruby client for the [Contentful](https://www.contentful.com) Content Delivery API.

[Contentful](https://www.contentful.com) is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Setup

Add to your Gemfile and bundle:

    gem 'contentful'


## Usage

    client = Contentful::Client.new(
      access_token: 'b4c0n73n7fu1',
      space: 'cfexampleapi'
    )

You can query for entries, assets, etc. very similar as described in the
[Delivery API Documentation](https://www.contentful.com/developers/documentation/content-delivery-api/). Please note, that **all methods of the Ruby client library are snake_cased, instead of JavaScript's camelCase**:

    client.content_types
    client.entry 'nyancat'

You can pass the usual filter options to the query:

    client.entries('sys.id[ne]' => 'nyancat') # query for all entries except 'nyancat'
    client.entries(include: 1) # include one level of linked resources


The results are returned as Contentful::Resource objects. Multiple results will be returned as Contentful::Array. The properties of a resource can be accessed through Ruby methods.

    content_type = client.content_type 'cat'
    content_type.description # "Meow."


Alternatively, the data can be accessed as Ruby `Hash` with symbolized keys (and in camelCase):

    content_type.properties # { name: '...', description: '...' }


System Properties behave the same and can be accessed via the `#sys` method.

    content_type.id # => 'cat'
    entry.type # => 'Entry'
    asset.sys # { id: '...', type: '...' }


Entry Fields usually don't have direct method accessors, since they are based on individual content types. These fields can be accessed through the `#fields` method:

    entry = client.entry 'nyancat'
    entry.fields[:color] # rainbow

Please note, that no field type conversions will be done for entries by default.


### Dynamic Entries

However, you can (and should) set `:dynamic_entries` to `:auto` in your client configuration. When using this option, the client will fetch all available content types and use them to create dynamic entries on the fly.

    client = Contentful::Client.new(
      access_token: 'b4c0n73n7fu1',
      space: 'cfexampleapi',
      dynamic_entries: :auto,
    )
    entry = client.entry 'nyancat' # => #<Contentful::DynamicEntry[cat]: ...>
    entry.color # => 'rainbow'

Dynamic entries will have getter classes for the fields and do type conversions properly.

The `:auto` mode will fetch all content types on initialization. If you want to do it by hand later, you will need to set the option to `:manual` and call `client.update_dynamic_entry_cache!` to initialize all dynamic entries.


### Arrays

Contentful::Array has an `#each` method that delegates to its items. It also includes Ruby's Enumerable module, providing methods like `#min` or `#first`. See the Ruby core documentation for further details.

Arrays also have a `#next_page` URL, which will rerun the request with a increased skip parameter, as described in [the documentation](https://www.contentful.com/developers/documentation/content-delivery-api/#search-limit).


### Links

You can easily request a resource that is represented by a link by calling `#resolve`:

    happycat = client.entry 'happycat'
    happycat.fields[:image]
    # => #<Contentful::Link: @sys={:type=>"Link", :linkType=>"Asset", :id=>"happycat"}>
    happycat.fields[:image].resolve # => #<Contentful::Asset: @fields={ ...


### Assets

There is a helpful method to add image resize options for an asset image:

    client.asset('happycat').image_url
    # => "//images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/
    #     382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg"

    client.asset('happycat').image_url width: 300, height: 200, format: 'jpg', quality: 100
    # => "//images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/
    #     382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg?w=300&h=200&fm=jpg&q=100"


### Resource Options

Resources, that have been requested directly (i.e. no child resources), can be fetched from the server again by calling `#reload`:

    entries = client.entries
    entries.reload # Fetches the array of entries again


### Field Type "Object"

While for known field types, the field data is accessible using methods or the `#fields` hash with symbol keys, it behaves differently for nested data of the type "Object". The client will treat them as arbitrary hashes and will not parse the data inside, which also means, this data is indexed by Ruby strings, not symbols.


## Client Configuration Options
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

`:auto` or `:manual`. See resource description above for details on usage.

### :raw_mode

Defaults to `false`. If enabled, the API responses will not be parsed to resource objects. Might be useful for debugging.

### :resource_mapping

See next paragraph for explanation


## Advanced Usage
### Custom Resource Classes

You can define your own classes that will be returned instead of the predefined ones. Consider, you want to build a better Asset class. One way to do this is:

    class MyBetterAsset < Contentful::Asset
      def https_image_url
        image_url.sub %r<\A//>, 'https://'
      end
    end

You can register your custom class on client initialization:

    client = Contentful::Client.new(
      space: 'cfexampleapi',
      access_token: 'b4c0n73n7fu1',
      resource_mapping: {
        'Asset' => MyBetterAsset
      }
    )

More information on `:resource_mapping` can be found in examples/resource_mapping.rb and more on custom classes in examples/custom_classes.rb

You can also register custom entry classes to be used based on the entry's content_type using the :entry_mapping configuration:

    class Cat < Contentful::Entry
      # define methods based on :fields, etc
    end

    client = Contentful::Client.new(
      space: 'cfexampleapi',
      access_token: 'b4c0n73n7fu1',
      entry_mapping: {
        'cat' => Cat
      }
    )

    client.entry('nyancat') # is instance of Cat


## Synchronization

The client also includes a wrapper for the synchronization endpoint. You can initialize it with the options described in the [Delivery API Documentation](https://www.contentful.com/developers/documentation/content-delivery-api/#sync) or an URL you received from a previous sync:

    client = Contentful::Client.new(
      access_token: 'b4c0n73n7fu1',
      space: 'cfexampleapi',
      default_locale: 'en-US'
    )
    s = client.sync(initial: true, type: 'Deletion') # Only returns deleted entries and assets
    s = client.sync("https://cdn.contentful.com/spaces/cfexampleapi/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4gr...sGPg") # Continues a sync

You can access the results either wrapped in `Contentful::SyncPage` objects:

    s.each_page do |page|
      # Find resources at: page.items
    end

    # More explicit version:
    page = s.first_page
    until s.completed?
      page = s.next_page
    end

Or directly iterative over all resources:

    s.each_item do |resource|
      # ...
    end

When a sync is completed, the next sync url can be read from the Sync or SyncPage object:

    s.next_sync_url

**Please note** that synchronization entries come in all locales, so make sure, you supply a :default_locale property to the client configuration, when using the sync feature. This will returned by default, when you call `Entry#fields`. The other localized data will also be saved and can be accessed by calling the fields method with a locale parameter:

    first_entry = client.sync(initial: true, type: 'Entry').first_page.items.first
    first_entry.fields('de-DE') # Returns German localizations


## License

Copyright (c) 2014 Contentful GmbH - Jan Lelis. See LICENSE.txt for further details.
