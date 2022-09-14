![header](./.github/header.png)
<p align="center">
  <a href="https://www.contentful.com/slack/">
    <img src="https://img.shields.io/badge/-Join%20Community%20Slack-2AB27B.svg?logo=slack&maxAge=31557600" alt="Join Contentful Community Slack">
  </a>
  &nbsp;
  <a href="https://www.contentfulcommunity.com/">
    <img src="https://img.shields.io/badge/-Join%20Community%20Forum-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600"
      alt="Join Contentful Community Forum">
  </a>
</p>

# contentful.rb - Contentful Ruby Delivery Library
[![Gem Version](https://badge.fury.io/rb/contentful.png)](http://badge.fury.io/rb/contentful)

> Ruby library for the Contentful [Content Delivery API](https://www.contentful.com/developers/docs/references/content-delivery-api/) and [Content Preview API](https://www.contentful.com/developers/docs/references/content-preview-api/). It helps you to easily access your Content stored in Contentful with your Ruby applications.

<p align="center">
  <img src="https://img.shields.io/badge/Status-Maintained-green.svg" alt="This repository is actively maintained" /> &nbsp;
  <a href="LICENSE.txt">
    <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License" />
  </a>
  &nbsp;
  <a href="https://app.circleci.com/pipelines/github/contentful/contentful.rb?branch=master">
    <img src="https://circleci.com/gh/contentful/contentful.rb/tree/master.svg?style=svg" alt="CircleCI">
  </a>
</p>

<p align="center">
  <a href="https://rubygems.org/gems/contentful">
    <img src="https://img.shields.io/gem/v/contentful.svg" alt="RubyGems version">
  </a>
  &nbsp;
  <a href="https://rubygems.org/gems/contentful">
    <img src="https://img.shields.io/gem/dt/contentful.svg" alt="RubyGems downloads">
  </a>
</p>

**What is Contentful?**

[Contentful](https://www.contentful.com/) provides content infrastructure for digital teams to power websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship their products faster.

<details>
<summary>Table of contents</summary>

<!-- TOC -->

- [contentful.rb - Contentful Ruby Delivery library](#contentfulrb---contentful-ruby-delivery-library)
  - [Core Features](#core-features)
  - [Getting started](#getting-started)
    - [Installation](#installation)
    - [Your first request](#your-first-request)
    - [Using this library with the Preview API](#using-this-library-with-the-preview-api)
    - [Authentication](#authentication)
  - [Documentation & References](#documentation--references)
    - [Configuration](#configuration)
    - [Reference documentation](#reference-documentation)
      - [Basic queries](#basic-queries)
      - [Filtering options](#filtering-options)
      - [Accessing fields and sys properties](#accessing-fields-and-sys-properties)
      - [Dynamic entries](#dynamic-entries)
      - [Using different locales](#using-different-locales)
      - [Arrays](#arrays)
      - [Links](#links)
      - [Assets](#assets)
      - [Resource options](#resource-options)
      - [Field type `Object`](#field-type-object)
    - [Advanced concepts](#advanced-concepts)
      - [Proxy example](#proxy-example)
      - [Custom resource classes](#custom-resource-classes)
      - [Synchronization](#synchronization)
    - [Migrating to 2.x](#migrating-to-2x)
    - [Tutorials & other resources](#tutorials--other-resources)
  - [Reach out to us](#reach-out-to-us)
    - [You have questions about how to use this library?](#you-have-questions-about-how-to-use-this-library)
    - [You found a bug or want to propose a feature?](#you-found-a-bug-or-want-to-propose-a-feature)
    - [You need to share confidential information or have other questions?](#you-need-to-share-confidential-information-or-have-other-questions)
  - [Get involved](#get-involved)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)

<!-- /TOC -->

</details>

## Core Features

- Content retrieval through [Content Delivery API](https://www.contentful.com/developers/docs/references/content-delivery-api/) and [Content Preview API](https://www.contentful.com/developers/docs/references/content-preview-api/).
- [Synchronization](https://www.contentful.com/developers/docs/concepts/sync/)
- [Localization support](https://www.contentful.com/developers/docs/concepts/locales/)
- [Link resolution](https://www.contentful.com/developers/docs/concepts/links/)
- Built in rate limiting recovery procedures
- Supports [Environments](https://www.contentful.com/developers/docs/concepts/multiple-environments/) (**since v2.6.0 - 16. April 2018**)

## Getting started

In order to get started with the Contentful Ruby library you'll need not only to install it, but also to get credentials which will allow you to have access to your content in Contentful.

- [Installation](#installation)
- [Your first request](#your-first-request)
- [Using this library with the Preview API](#using-this-library-with-the-preview-api)
- [Authentication](#authentication)
- [Documentation & References](#documentation--references)

### Installation

Add to your Gemfile and bundle:

```bash
gem 'contentful'
```

Or install it directly from your console:

```bash
gem i contentful
```

### Your first request

The following code snippet is the most basic one you can use to get some content from Contentful with this library:

```ruby
require 'contentful'

client = Contentful::Client.new(
  space: 'cfexampleapi',  # This is the space ID. A space is like a project folder in Contentful terms
  access_token: 'b4c0n73n7fu1'  # This is the access token for this space. Normally you get both ID and the token in the Contentful web app
)

# This API call will request an entry with the specified ID from the space defined at the top, using a space-specific access token.
entry = client.entry('nyancat')
```

### Using this library with the Preview API

This library can also be used with the Preview API. In order to do so, you need to use the Preview API Access token, available on the same page where you get the Delivery API token, and specify the host of the preview API, such as:

```ruby
require 'contentful'

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  api_url: 'preview.contentful.com'
)
```

You can query for entries, assets, etc. very similar as described in the
[Delivery API Documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/). Please note, that **all methods of the Ruby client library are snake_cased, instead of JavaScript's camelCase**:

### Authentication

To get your own content from Contentful, an app should authenticate with an OAuth bearer token.

You can create API keys using the [Contentful web interface](https://app.contentful.com). Go to the app, open the space that you want to access (top left corner lists all the spaces), and navigate to the APIs area. Open the API Keys section and create your first token. Done.

Don't forget to also get your Space ID.

For more information, check the [Contentful REST API reference on Authentication](https://www.contentful.com/developers/docs/references/authentication/).

## Documentation & References

- [Configuration](#configuration)
- [Reference documentation](#reference-documentation)
- [Tutorials & other resources](#tutorials--other-resources)
- [Advanced Concepts](#advanced-concepts)
- [Migrating to 2.x](#migrating-to-2x)


To help you get the most out of this library, we've prepared all available client configuration options, reference documentation, tutorials and other examples that will help you learn and understand how to use this library.

### Configuration

The client constructor supports several options you may set to achieve the expected behavior:

```ruby
client = Contentful::Client.new(
  # ... your options here ...
)
```

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Default</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td></td>
      <td><strong>Required</strong>. Your access token.</td>
    </tr>
    <tr>
      <td><code>space</code></td>
      <td></td>
      <td><strong>Required</strong>. Your space ID.</td>
    </tr>
    <tr>
      <td><code>environment</code></td>
      <td>'master'</td>
      <td>Your environment ID.</td>
    </tr>
    <tr>
      <td><code>api_url</code></td>
      <td><code>'cdn.contentful.com'</code></td>
      <td>Set the host used to build the request URIs.</td>
    </tr>
    <tr>
      <td><code>default_locale</code></td>
      <td><code>'en-US'</code></td>
      <td>Defines default locale for the client.</td>
    </tr>
    <tr>
      <td><code>secure</code></td>
      <td><code>true</code></td>
      <td>Defines whether to use HTTPS or HTTP. By default we use HTTPS.</td>
    </tr>
    <tr>
      <td><code>authentication_mechanism</code></td>
      <td><code>:header</code></td>
      <td>Sets the authentication mechanisms, valid options are <code>:header</code> or <code>:query_string</code></td>
    </tr>
    <tr>
      <td><code>raise_errors</code></td>
      <td><code>true</code></td>
      <td>Determines whether errors are raised or returned.</td>
    </tr>
    <tr>
      <td><code>raise_for_empty_fields</code></td>
      <td><code>true</code></td>
      <td>Determines whether <code>EmptyFieldError</code> is raised when empty fields are requested on an entry or <code>nil</code> is returned.</td>
    </tr>
    <tr>
      <td><code>dynamic_entries</code></td>
      <td><code>:manual</code></td>
      <td>
        Determines if content type caching is enabled automatically or not,
        allowing for accessing of fields even when they are not present on the response.
        Valid options are <code>:auto</code> and <code>:manual</code>.
      </td>
    </tr>
    <tr>
      <td><code>raw_mode</code></td>
      <td><code>false</code></td>
      <td>If enabled, API responses are not parsed and the raw response object is returned instead.</td>
    </tr>
    <tr>
      <td><code>resource_mapping</code></td>
      <td><code>{}</code></td>
      <td>Allows for overriding default resource classes with custom ones.</td>
    </tr>
    <tr>
      <td><code>entry_mapping</code></td>
      <td><code>{}</code></td>
      <td>Allows for overriding of specific entry classes by content type.</td>
    </tr>
    <tr>
      <td><code>gzip_encoded</code></td>
      <td><code>true</code></td>
      <td>Enables gzip response content encoding.</td>
    </tr>
    <tr>
      <td><code>max_rate_limit_retries</code></td>
      <td><code>1</code></td>
      <td>
        To increase or decrease the retry attempts after a 429 Rate Limit error. Default value is 1. Using 0 will disable retry behaviour.
        Each retry will be attempted after the value (in seconds) of the <code>X-Contentful-RateLimit-Reset</code> header,
        which contains the amount of seconds until the next non rate limited request is available, has passed.
        This is blocking per execution thread.
      </td>
    </tr>
    <tr>
      <td><code>max_rate_limit_wait</code></td>
      <td><code>60</code></td>
      <td>
        Maximum time to wait for next available request (in seconds). Default value is 60 seconds.
        Keep in mind that if you hit the hourly rate limit maximum, you can have up to 60 minutes of blocked requests.
        It is set to a default of 60 seconds in order to avoid blocking processes for too long, as rate limit retry behaviour
        is blocking per execution thread.
      </td>
    </tr>
    <tr>
      <td><code>max_include_resolution_depth</code></td>
      <td><code>20</code></td>
      <td>
        Maximum amount of levels to resolve includes for library entities
        (this is independent of API-level includes - it represents the maximum depth the include resolution
        tree is allowed to resolved before falling back to <code>Link</code> objects).
        This include resolution strategy is in place in order to avoid having infinite circular recursion on resources with circular dependencies.
        <strong>Note</strong>: If you're using something like <code>Rails::cache</code> it's advisable to considerably lower this value
        (around 5 has proven to be a good compromise - but keep it higher or equal than your maximum API-level include parameter if you need the entire tree resolution).
        Note that when <code>reuse_entries</code> is enabled, the max include resolution depth only affects
        deep chains of unique objects (ie, not simple circular references).
      </td>
    </tr>
    <tr>
      <td><code>reuse_entries</code></td>
      <td><code>false</code></td>
      <td>
        When enabled, reuse hydrated Entry and Asset objects within the same request when possible.
        Can result in a large speed increase and better handles cyclical object graphs.
        This can be a good alternative to <code>max_include_resolution_depth</code> if your content model contains (or can contain) circular references.
        <strong>Caching may break if this option is enabled, as it may generate stack errors.</strong>
        When caching, deactivate this option and opt for a conservative <code>max_include_resolution_depth</code> value.
      </td>
    </tr>
    <tr>
      <td><code>use_camel_case</code></td>
      <td><code>false</code></td>
      <td>
        When doing the v2 upgrade, all keys and accessors were changed to always use <code>snake_case</code>.
        This option introduces the ability to use <code>camelCase</code> for keys and method accessors.
        This is very useful for isomorphic applications.
      </td>
    </tr>
    <tr>
      <td><code>proxy_host</code></td>
      <td><code>nil</code></td>
      <td>To be able to perform a request behind a proxy, this needs to be set. It can be a domain or IP address of the proxy server.</td>
    </tr>
    <tr>
      <td><code>proxy_port</code></td>
      <td><code>nil</code></td>
      <td>Specify the port number that is used by the proxy server for client connections.</td>
    </tr>
    <tr>
      <td><code>proxy_username</code></td>
      <td><code>nil</code></td>
      <td>Username for proxy authentication.</td>
    </tr>
    <tr>
      <td><code>proxy_password</code></td>
      <td><code>nil</code></td>
      <td>Password for proxy authentication.</td>
    </tr>
    <tr>
      <td><code>timeout_read</code></td>
      <td><code>nil</code></td>
      <td>Number of seconds the request waits to read from the server before timing out.</td>
    </tr>
    <tr>
      <td><code>timeout_write</code></td>
      <td><code>nil</code></td>
      <td>Number of seconds the request waits when writing to the server before timing out.</td>
    </tr>
    <tr>
      <td><code>timeout_connect</code></td>
      <td><code>nil</code></td>
      <td>Number of seconds the request waits to connect to the server before timing out.</td>
    </tr>
    <tr>
      <td><code>logger</code></td>
      <td><code>nil</code></td>
      <td>To enable logging pass a logger instance compatible with <code>::Logger</code>.</td>
    </tr>
    <tr>
      <td><code>log_level</code></td>
      <td><code>::Logger::INFO</code></td>
      <td>
        The default severity is set to INFO and logs only the request attributes (headers, parameters and url).
        Setting it to DEBUG will also log the raw JSON response.
        WARNING: Setting this will override the level on the logger instance. Leave out this key to preserve
        the original log_level on the logger, for example when using Rails.logger.
      </td>
    </tr>
  </tbody>
</table>

### Reference documentation

#### Basic queries

```ruby
content_types = client.content_types
cat_content_type = client.content_type 'cat'
nyancat = client.entry 'nyancat'
entries = client.entries
assets = client.assets
nyancat_asset = client.asset 'nyancat'
```

#### Filtering options

You can pass the usual filter options to the query:

```ruby
client.entries(content_type: 'cat') # query for a content-type by its ID (not name)
client.entries('sys.id[ne]' => 'nyancat') # query for all entries except 'nyancat'
client.entries(include: 1) # include one level of linked resources
client.entries(content_type: 'cat', include: 1) # you can also combine multiple parameters
```

To read more about filtering options you can check our [search parameters documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters).

The results are returned as `Contentful::BaseResource` objects. Multiple results will be returned as `Contentful::Array`.
The properties of a resource can be accessed through Ruby methods.

#### Accessing fields and sys properties

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

Entry fields also have direct accessors and will be coerced to the type defined in it's content type.
However, if using `dynamic_entries: :manual`, coercion will not be done.

```ruby
entry = client.entry 'nyancat'
entry.fields[:color] # 'rainbow'
entry.color # 'rainbow'
entry.birthday # #<DateTime: 2011-04-04T22:00:00+00:00 ((2455656j,79200s,0n),+0s,2299161j)>
```

#### Accessing tags

Tags can be accessed via the `#_metadata` method.

```ruby
entry = client.entry 'nyancat'
entry._metadata[:tags] # => [<Contentful::Link id='tagID'>]
```

#### Dynamic entries

However, you can (and should) set `:dynamic_entries` to `:auto` in your client configuration.
When using this option, the client will cache all available content types and use them to hydrate entries when fields are missing in the response and coerce fields to their proper types.

```ruby
client = Contentful::Client.new(
  access_token: 'b4c0n73n7fu1',
  space: 'cfexampleapi',
  dynamic_entries: :auto
)

entry = client.entry 'nyancat' # => #<Contentful::Entry[cat]: ...>
entry.color # => 'rainbow'
entry.birthday # #<DateTime: 2011-04-04T22:00:00+00:00 ((2455656j,79200s,0n),+0s,2299161j)>
```

Dynamic entries will have getter classes for the fields and do type conversions properly.

The `:auto` mode will fetch all content types on initialization. If you want to do it by hand later, you will need to set the option to `:manual` and call `client.update_dynamic_entry_cache!` to initialize the cache.

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

#### Arrays

Contentful::Array has an `#each` method that delegates to its items. It also includes Ruby's Enumerable module, providing methods like `#min` or `#first`. See the Ruby core documentation for further details.

Arrays also have a `#next_page` URL, which will rerun the request with a increased skip parameter, as described in [the documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters/skip).


#### Links

You can easily request a resource that is represented by a link by calling `#resolve`:

```ruby
happycat = client.entry 'happycat'
happycat.image
# => #<Contentful::Link: @sys={:type=>"Link", :linkType=>"Asset", :id=>"happycat"}>
happycat.image.resolve(client) # => #<Contentful::Asset: @fields={ ...
```

### Assets

There is a helpful method to add image resize options for an asset image:

```ruby
client.asset('happycat').url
# => "//images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/
#     382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg"

client.asset('happycat').url(width: 300, height: 200, format: 'jpg', quality: 100)
# => "//images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/
#     382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg?w=300&h=200&fm=jpg&q=100"
```

#### Resource options

Resources, that have been requested directly (i.e. no child resources), can be fetched from the server again by calling `#reload`:

```ruby
entries = client.entries
entries.reload # Fetches the array of entries again
```

#### Field type `Object`

While for known field types, the field data is accessible using methods or the `#fields` hash with symbol keys, it behaves differently for nested data of the type "Object".
The client will treat them as arbitrary hashes and will not parse the data inside.


### Advanced concepts

#### Proxy example

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

#### Custom resource classes

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

More information on `:resource_mapping` can be found in [examples/resource_mapping.rb](./examples/resource_mapping.rb)
and more on custom classes in [examples/custom_classes.rb](./examples/custom_classes.rb).

You can also register custom entry classes to be used based on the entry's content_type using the `:entry_mapping` configuration:

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

#### Synchronization

The client also includes a wrapper for the synchronization endpoint.
You can initialize it with the options described in the
[Delivery API Documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/synchronization)
or an URL you received from a previous sync:

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

### Migrating to 2.x

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

### Tutorials & other resources

* This library is a wrapper around our Contentful Delivery REST API. Some more specific details such as search parameters and pagination are better explained on the [REST API reference](https://www.contentful.com/developers/docs/references/content-delivery-api/), and you can also get a better understanding of how the requests look under the hood.
* Check the [Contentful for Ruby](https://www.contentful.com/developers/docs/ruby/) page for Tutorials, Demo Apps, and more information on other ways of using Ruby with Contentful

## Reach out to us

### You have questions about how to use this library?
* Reach out to our community forum: [![Contentful Community Forum](https://img.shields.io/badge/-Join%20Community%20Forum-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600)](https://support.contentful.com/)
* Jump into our community slack channel: [![Contentful Community Slack](https://img.shields.io/badge/-Join%20Community%20Slack-2AB27B.svg?logo=slack&maxAge=31557600)](https://www.contentful.com/slack/)

### You found a bug or want to propose a feature?

* File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/contentful/contentful.rb/issues/new). Make sure to remove any credential from your code before sharing it.

### You need to share confidential information or have other questions?

* File a support ticket at our Contentful Customer Support: [![File support ticket](https://img.shields.io/badge/-Submit%20Support%20Ticket-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600)](https://www.contentful.com/support/)

## Get involved

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?maxAge=31557600)](http://makeapullrequest.com)

We appreciate any help on our repositories. For more details about how to contribute see our [CONTRIBUTING.md](CONTRIBUTING.md) document.

## License

This repository is published under the [MIT](LICENSE.txt) license.

## Code of Conduct

We want to provide a safe, inclusive, welcoming, and harassment-free space and experience for all participants, regardless of gender identity and expression, sexual orientation, disability, physical appearance, socioeconomic status, body size, ethnicity, nationality, level of experience, age, religion (or lack thereof), or other identity markers.

[Read our full Code of Conduct](https://github.com/contentful-developer-relations/community-code-of-conduct).
