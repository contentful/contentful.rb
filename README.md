# contentful.rb
[![Gem Version](https://badge.fury.io/rb/contentful.png)](http://badge.fury.io/rb/contentful) [![Build Status](https://travis-ci.org/contentful/contentful.rb.png)](https://travis-ci.org/contentful/contentful.rb) [![Coverage Status](https://coveralls.io/repos/contentful/contentful.rb/badge.png?branch=master)](https://coveralls.io/r/contentful/contentful.rb?branch=master)

Ruby client for the [Contentful](https://www.contentful.com) Content Delivery API.

[Contentful](https://www.contentful.com) is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

**IMPORTANT**: We're collecting feedback before releasing version 2.0.0 of the SDK, if you're interested in helping, please drop by this issue and help us improving: https://github.com/contentful/contentful.rb/issues/120

## Setup

Add to your Gemfile and bundle:

```bash
gem 'contentful'
```

## Usage

```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi'
)
```

If you plan on using the [Preview API](https://www.contentful.com/developers/docs/references/content-preview-api/) you need to specify the `api_url`:

```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi',
  api_url: 'preview.contentful.com'
)
```

You can query for entries, assets, etc. very similar as described in the
[Delivery API Documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/). Please note, that **all methods of the Ruby client library are snake_cased, instead of JavaScript's camelCase**:

```ruby
client.content_types
client.entry 'nyancat'
```

You can pass the usual filter options to the query:

```ruby
client.entries(content_type: 'cat') # query for a content-type by its ID (not name)
client.entries('sys.id[ne]' => 'nyancat') # query for all entries except 'nyancat'
client.entries(include: 1) # include one level of linked resources
client.entries(content_type: 'cat', include: 1) # you can also combine multiple parameters
```

The results are returned as Contentful::Resource objects. Multiple results will be returned as Contentful::Array. The properties of a resource can be accessed through Ruby methods.

```ruby
content_type = client.content_type 'cat'
content_type.description # "Meow."
```

System Properties behave the same and can be accessed via the `#sys` method.

```ruby
content_type.id # => 'cat'
entry.type # => 'Entry'
asset.sys # { id: '...', type: '...' }
```

Entry Fields usually don't have direct method accessors, since they are based on individual content types. These fields can be accessed through the `#fields` method:

```ruby
entry = client.entry 'nyancat'
entry.fields[:color] # rainbow
```

Please note, that no field type conversions will be done for entries by default.

### Dynamic Entries

However, you can (and should) set `:dynamic_entries` to `:auto` in your client configuration. When using this option, the client will fetch all available content types and use them to create dynamic entries on the fly.

```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi',
  dynamic_entries: :auto
)

entry = client.entry 'nyancat' # => #<Contentful::DynamicEntry[cat]: ...>
entry.color # => 'rainbow'
```

Dynamic entries will have getter classes for the fields and do type conversions properly.

The `:auto` mode will fetch all content types on initialization. If you want to do it by hand later, you will need to set the option to `:manual` and call `client.update_dynamic_entry_cache!` to initialize all dynamic entries.

#### Using different locales

Entries can have multiple locales, by default, the client only fetches the entry with only its default locale.
If you want to fetch a different locale you can do the following:

```ruby
entries = client.entries(locale: 'de-DE')
```

Then all the fields will be fetched for the requested locale.

Contentful Delivery API also allows to fetch all locales, you can do so by doing:

```ruby
entries = client.entries(content_type: 'cat', locale: '*')

# assuming the entry has a field called name
my_spanish_name = entries.first.fields('es-AR')[:name]
```

When requesting multiple locales, the object accessor shortcuts only work for the default locale.

### Arrays

Contentful::Array has an `#each` method that delegates to its items. It also includes Ruby's Enumerable module, providing methods like `#min` or `#first`. See the Ruby core documentation for further details.

Arrays also have a `#next_page` URL, which will rerun the request with a increased skip parameter, as described in [the documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters/skip).


### Links

You can easily request a resource that is represented by a link by calling `#resolve`:

```ruby
happycat = client.entry 'happycat'
happycat.fields[:image]
# => #<Contentful::Link: @sys={:type=>"Link", :linkType=>"Asset", :id=>"happycat"}>
happycat.fields[:image].resolve # => #<Contentful::Asset: @fields={ ...
```

### Assets

There is a helpful method to add image resize options for an asset image:

```ruby
client.asset('happycat').image_url
# => "//images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/
#     382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg"

client.asset('happycat').image_url width: 300, height: 200, format: 'jpg', quality: 100
# => "//images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/
#     382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg?w=300&h=200&fm=jpg&q=100"
```

### Resource Options

Resources, that have been requested directly (i.e. no child resources), can be fetched from the server again by calling `#reload`:

```ruby
entries = client.entries
entries.reload # Fetches the array of entries again
```

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

### :gzip_encoded

Enables gzip response content encoding, default to: true

### :logger

Logging is disabled by default, it can be enabled by setting a logger instance and a logging severity.
```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi',
  logger: logger_instance,
  log_level: Logger::DEBUG
)
```
Example loggers:

```ruby
Rails.logger
Logger.new('logfile.log')
```

### :log_level
The default severity is set to INFO and logs only the request attributes (headers, parameters and url). Setting it to DEBUG will also log the raw JSON response.

### :proxy_host

To be able to perform a request behind a proxy, you need to specify a ```:proxy_host```.  This can be a domain or IP address of the proxy server.

### :proxy_port

Specify the port number that is used by the proxy server for client connections.

### :port_password, :port_username

To use the proxy with authentication, you need to specify ```port_username``` and ```port_password```.

### :max_rate_limit_retries

To increase or decrease the retry attempts after a 429 Rate Limit error. Default value is 1. Using 0 will disable retry behaviour.
Each retry will be attempted after the value (in seconds) of the `X-Contentful-RateLimit-Reset` header, which contains the amount of seconds until the next
non rate limited request is available, has passed. This is blocking per execution thread.

### :max_rate_limit_wait

Maximum time to wait for next available request (in seconds). Default value is 60 seconds. Keep in mind that if you hit the houly rate limit maximum, you
can have up to 60 minutes of blocked requests. It is set to a default of 60 seconds in order to avoid blocking processes for too long, as rate limit retry behaviour
is blocking per execution thread.

### :max_include_resolution_depth

Maximum amount of levels to resolve includes for SDK entities (this is independent of API-level includes - it represents the maximum depth the include resolution
tree is allowed to resolved before falling back to `Link` objects). This include resolution strategy is in place in order to avoid having infinite circular recursion
on resources with circular dependencies. Defaults to 20. _Note_: If you're using something like `Rails::cache` it's advisable to considerably lower this value
(around 5 has proven to be a good compromise - but keep it higher or equal than your maximum API-level include parameter if you need the entire tree resolution).

### Proxy example

```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi',
  proxy_host: '127.0.0.1',
  proxy_port: 8080,
  proxy_username: 'username',
  proxy_password: 'secret_password',
)
```

## Advanced Usage
### Custom Resource Classes

You can define your own classes that will be returned instead of the predefined ones. Consider, you want to build a better Asset class. One way to do this is:

```ruby
class MyBetterAsset < Contentful::Asset
  def https_image_url
    image_url.sub %r<\A//>, 'https://'
  end
end
```

You can register your custom class on client initialization:

```ruby
client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  resource_mapping: {
    'Asset' => MyBetterAsset
  }
)
```

More information on `:resource_mapping` can be found in examples/resource_mapping.rb and more on custom classes in examples/custom_classes.rb

You can also register custom entry classes to be used based on the entry's content_type using the :entry_mapping configuration:

```ruby
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
```

## Synchronization

The client also includes a wrapper for the synchronization endpoint. You can initialize it with the options described in the [Delivery API Documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/synchronization) or an URL you received from a previous sync:

```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi',
  default_locale: 'en-US'
)

sync = client.sync(initial: true, type: 'Deletion') # Only returns deleted entries and assets
sync = client.sync("https://cdn.contentful.com/spaces/cfexampleapi/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4gr...sGPg") # Continues a sync
```

You can access the results either wrapped in `Contentful::SyncPage` objects:

```ruby
sync.each_page do |page|
  # Find resources at: page.items
end

# More explicit version:
page = sync.first_page
until sync.completed?
  page = sync.next_page
end
```

Or directly iterative over all resources:

```ruby
sync.each_item do |resource|
  # ...
end
```

When a sync is completed, the next sync url can be read from the Sync or SyncPage object:

```ruby
sync.next_sync_url
```

**Please note** that synchronization entries come in all locales, so make sure, you supply a :default_locale property to the client configuration, when using the sync feature. This locale will be returned by default, when you call `Entry#fields`. The other localized data will also be saved and can be accessed by calling the fields method with a locale parameter:

```ruby
first_entry = client.sync(initial: true, type: 'Entry').first_page.items.first
first_entry.fields('de-DE') # Returns German localizations
```

## Workarounds

- When an entry has related entries that are unpublished, they still end up in the resource as unresolved links. We consider this correct, because it is in line with the API responses and our other SDKs. However, you can use the workaround from [issue #60](/../../issues/60) if you happen to want this working differently.

## Migrating to 2.x

If you're a `0.x` or a `1.x` user of this gem, and are planning to migrate to the current `2.x` branch.
There are a few breaking changes you have to take into account:

* `Contentful::Link#resolve` and `Contentful::Array#next_page` now require a `Contentful::Client` instance as a parameter.
* `Contentful::CustomResource` does no longer exist, custom entry classes can now inherit from `Contentful::Entry` and have proper marshalling working.
* `Contentful::Resource` does no longer exist, all resource classes now inherit from `Contentful::BaseResource`. `Contentful::Entry` and `Contentful::Asset` inherit from `Contentful::FieldsResource` which is a subclass of `Contentful::BaseResource`.
* `Contentful::DynamicEntry` does no longer exist, if code checked against that base class, it should now check against `Contentful::Entry` instead.
* `Contentful::Client#dynamic_entry_cache` _(private)_ has been extracted to it's own class, and can be now manually cleared by using `Contentful::ContentTypeCache::clear`.
* `Contentful::BaseResource#sys` and `Contentful::FieldsResource#fields` internal representation for keys are now snake cased to match the instance accessors. E.g. `entry.fields[:myField]` previously had the accessor `entry.my_field`, now it is `entry.fields[:my_field]`. The value in both cases would correspond to the same field, only change is to unify the style. If code accessed the values through the `#sys` or `#fields` methods, keys now need to be snake cased.
* Circular references are handled as individual objects to simplify marshalling and reduce stack errors, this introduces a performance hit on extremely interconnected content. Therefore, to limit the impact of circular references, an additional configuration flag `max_include_resolution_depth` has been added. It is set to 20 by default (which corresponds to the maximum include level value * 2). This allows for non-circular but highly connected content to resolve properly. In very interconnected content, it also allows to reduce this number to improve performance. For a more in depth look into this you can read [this issue](https://github.com/contentful/contentful.rb/issues/124#issuecomment-287002469).
* `#inspect` now offers a clearer and better output for all resources. If your code had assertions based on the string representation of the resources, update to the new format `<Contentful::#{RESOURCE_CLASS}#{additional_info} id="#{RESOURCE_ID}">`.

For more information on the internal changes present in the 2.x release, please read the [CHANGELOG](CHANGELOG.md)

## License

Copyright (c) 2014 Contentful GmbH - Jan Lelis.
Copyright (c) 2016 Contentful GmbH - David Litvak.

See LICENSE.txt for further details.
