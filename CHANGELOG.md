# Change Log

## 2.17.0

### Updated
* Updated `http` gem version

### Changed
* CI/CD vendor from travis to circleci
* Refactored `includes` to be a model (`Contentful::Includes`) with a lookup table instead of a plain Ruby array, for improved performance when `include_level` is set. Two related methods from `Support` have been moved to this new class. Any code that uses the undocumented `includes_for_single` option to any method will need to be updated. [#235](https://github.com/contentful/contentful.rb/pull/235)

## 2.16.3
### Fixed
* Fixed an issue where `raw['metadata']` was unexpectedly overwritten by `BaseResource#hydrate_metadata` method.

## 2.16.2
### Fixed
* Fixed an issue where entry's `raw['fields']` was unexpectedly overwritten by `FieldsResource#raw_with_links` method.

## 2.16.1
* Removed unncessary files from gem release package.

## 2.16.0

### Added
* Added `Contentful::ArrayLike#to_ary`. [#200](https://github.com/contentful/contentful.rb/issues/200)
* Added `_metadata[:tags]` to read metadata tags on `entry` and `asset`.

## 2.15.4

### Fixed
* Fixed an issue where the `log_level` of `Logger` was changed unintentionally [#222](https://github.com/contentful/contentful.rb/pull/222)
* Fixed an issue cause by a `Logger` not being correctly thrown away, causing an exception. [#220](https://github.com/contentful/contentful.rb/pull/220)
* Added `title` field to assets to prevent Error raising when the field is empty. [#218](https://github.com/contentful/contentful.rb/pull/218)
* Fixed an issue with `ArrayLike` not taking multiple arguments leading to Errors when using it with pagination libraries. [#215](https://github.com/contentful/contentful.rb/pull/215)

## 2.15.3
### Fixed
* Fixed a deprecation warning in Ruby 2.7.0 for `URI::escape` and replaced it with a backwards compatible mechanism. [#217](https://github.com/contentful/contentful.rb/issues/217)

## 2.15.2
### Fixed
* Fixed unresolvable single linked entries and assets returning a JSON Link rather than being `nil`, the same way they are filtered from Link arrays.

## 2.15.1
### Fixed
* Fixed how `entry_mapping` is cached in order to avoid errors when deserializing resources that have been serialized with previously deleted mapping classes. [#212](https://github.com/contentful/contentful.rb/issues/212)

## 2.15.0
### Added
* Added the capability for `Array#next_page` to support carry-over of query parameters.

## 2.14.0
### Added
* Allow user defined methods to override properties created by the SDK, if you want to access overriden fields or sys properties use `#fields[]` or `#sys[]` as accessors. [#210](https://github.com/contentful/contentful.rb/pull/210)

## 2.13.3
### Fixed
* Fixed unfiltered unresolvable entries and assets from re-marshalled entries. [#207](https://github.com/contentful/contentful.rb/pull/207)

## 2.13.2
### Fixed
* Removed unnecessary object dups and moved some static arrays that were regenerated each time to constants.

## 2.13.1
### Fixed
* Fixed detection of empty fields when `:use_camel_case` is `true`. [#203](https://github.com/contentful/contentful.rb/issues/203)

## 2.13.0
### Changed
* Updated HTTP gem version limits. [#202](https://github.com/contentful/contentful.rb/pull/202)

## 2.12.0
### Added
* Add HTTP timeout configuration. [#196](https://github.com/contentful/contentful.rb/pull/196)

## 2.11.1
### Fixed
* Fixed coercion error when same entry was included more than once in the same RichText field. [#194](https://github.com/contentful/contentful.rb/pull/194)

## 2.11.0
### Added
* Added `:raise_for_empty_fields` configuration option. [#190](https://github.com/contentful/contentful.rb/issues/190)

### Fixed
* Links in `RichText` fields, that are published but unreachable, due to not having enough include depth on the request, are now returned as `Link` objects.

### Changed
* Included resources for embedded entries and assets in Rich Text fields are now properly serialized to `data.target` instead of the top level `data`.

## 2.10.1
### Fixed
* Fixed `Marshal.load` for entries with unpublished related entries.

## 2.10.0

As `RichText` moves from `alpha` to `beta`, we're treating this as a feature release.

### Changed
* Renamed `StructuredText` to `RichText`.

## 2.9.4
### Fixed
* Fixed incorrect default error message for `503 Service Unavailable` errors. [#183](https://github.com/contentful/contentful.rb/issues/183)

## 2.9.3
### Fixed
* Added safeguard for re-serialization of `StructuredText` nodes.

## 2.9.2
### Added
* Added support for `StructuredText` inline Entry include resolution.

## 2.9.1

**Note:** This release includes support for `StructuredText`, this is an **alpha** feature and changes are to be expected. Further releases of this feature
will not increase a major version even if changes are breaking.

### Added
* Added support for `StructuredText` field type.

### Fixed
* Fixed `DateCoercion` when value is already a `Date`, `DateTime` or `Time` object. [contentful_model/#121](https://github.com/contentful/contentful_model/issues/121)

## 2.9.0 **YANKED**

Yanked due to faulty release

## 2.8.1
### Fixed
* Fixed deeply nested resources now also filter unresolvable entries. [#177](https://github.com/contentful/contentful.rb/issues/177)

## 2.8.0
### Added
* Added support for `sync` on environments other than `master`.

## 2.7.0
### Added
* Added support for `radius` cropping on the Asset `#url`.

## 2.6.0
### Changed
* Makes all routes environment aware. This change is not backwards incompatible.

### Added
* Added `locales` endpoint to retrieve locales from an environment.

## 2.5.0
### Added
* Add filtering of invalid entries from API responses.

## 2.4.0
### Added
* Added `reuse_entries` option to client configuration. This is a performance improvement, which is disabled by default due to backwards compatibility. All users are highly encouraged to enable it and test it in their applications. [#164](https://github.com/contentful/contentful.rb/pull/164)

## 2.3.0
### Added
* Support for the new query parameters to find incoming links [to a specific entry](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters/links-to-entry) or [to a specific asset](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters/links-to-asset) in a space.

### Fixed
* Fixes coercion issue when `DateTime` values are `nil`. [#148](https://github.com/contentful/contentful.rb/issues/148)

## 2.2.2
### Fixed
* Fixed 404 error when `details` object contains a top level `sys` key.

## 2.2.1
### Fixed
* Fixed an edge case of 404 error having details as a string.

## 2.2.0
### Added
* Added `:use_camel_case` option to client. [#142](https://github.com/contentful/contentful.rb/issues/142)
* Added better error handling for all error types.

### Fixed
* Fixed JSON field coercion when field contains other valid JSON elements other than objects at the top level.

## 2.1.3
### Fixed
* Fixed Marshalling for custom resources in Arrays. [#138](https://github.com/contentful/contentful.rb/issues/138)

## 2.1.2
### Fixed
* Fixed Marshalling for Arrays with deeply nested resources. [#138](https://github.com/contentful/contentful.rb/issues/138)

## 2.1.1

### Fixed
* Fixed Marshalling for resources that have deeply nested resources. [#138](https://github.com/contentful/contentful.rb/issues/138)

## 2.1.0
### Added
* Added `X-Contentful-User-Agent` header for more information.

## 2.0.3

### Fixed

* `Contentful::Array` now marshalls properly, respecting all properties [#132](https://github.com/contentful/contentful.rb/issues/132)

## 2.0.2

### Fixed
* Asset File Mapping now uses `#internal_resource_locale` to use `Resource#sys[:locale]` if available [jekyll-contentful-data-import #46](https://github.com/contentful/jekyll-contentful-data-import/issues/46)

## 2.0.1

### Fixed
* Fixed Integer/Decimal field serializations [#125](https://github.com/contentful/contentful.rb/issues/125)
* Fixed File coercion for Localized Assets [#129](https://github.com/contentful/contentful.rb/issues/129)

## 2.0.0

**ATTENTION**: Breaking Changes introduces in order to simplify code and improve the ability to add new features.

### Changed

* The removal of the Client and Request objects from the Resource objects, means that for example: Link#resolve and Array#next_page now require the client as a parameter.
* Client#entry now uses /entries?sys.id=ENTRY_ID instead of /entries/ENTRY_ID to properly resolve includes.
* Refactor locale handling code
* Refactor ResourceBuilder
* Update all specs to RSpec 3
* Removed DynamicEntry and Resource
* Moved ContentTypeCache outside of the client into it's own class
* Added new base BaseResource and FieldsResource classes to handle common resource attributes and fields related attributes respectively
* Coercions are now part of ContentType, each Field knows which coercion should be applied depending on Field#type
* Resource #inspect now provides a clearer and better output, without all the noise that was previously there
* CustomResource was removed, now subclasses of Entry should be used instead.
* `max_include_resolution_depth` option added to the client, defaults to 20.
* `sys` properties now match accessors.
* `fields` properties now match accessors.
* Updated LICENSE
* Updated examples

## 1.2.2
### Fixed
* Fixed Symbol/Text field serialization when value is `null` [#117](https://github.com/contentful/contentful.rb/issues/117)

## 1.2.1
### Added
* Update dependency versions

## 1.2.0
### Added
* Add alias for `image_url`

## 1.1.1
### Fixed
* Fix Re-Marshalling of already Un-Marshalled objects

## 1.1.0
### Added
* Add support for `select` operator in `#entries` and `#assets` call

## 1.0.2
### Fixed
* Fix Link resolution for Arrays on localized content

### Added
* Add `entry?` method to resources to easily detect entries
* Add missing documentation for `#locales` method

## 1.0.1
### Fixed
* Fix Link resolution on localized content

### Changed
* Removed dependency lock specific for Ruby < 2.0 support

## 1.0.0

**ATTENTION**: Breaking changes on how JSON Fields are parsed. All keys are now symbolized, including
nested hashes. Parsing errors have been fixed, particularly for `array`, `null` and `boolean` present on the first
level of the JSON field. Also, on release 0.11.0, it was fixed that JSON Fields were being treated as locales.
This change increases consistency for the SDK, treating everything the same way. We strive for consistency and
quality in our tools.

The following `diff` shows previous and current state. This is the contents of the JSON Field we test this feature against.

```diff
- {:null=>"",
-  :text=>"some text",
-  :array=>"[1, 2, 3]",
-  :number=>123,
-  :object=>
-   {"null"=>nil,
-    "text"=>"bar",
-    "array"=>[1, 2, 3],
-    "number"=>123,
-    "object"=>{"foo"=>"bar"},
-    "boolean"=>false},
-  :boolean=>"true"}
+ {:null=>nil,
+  :text=>"some text",
+  :array=>[1, 2, 3],
+  :number=>123,
+  :object=>
+   {:null=>nil,
+   :text=>"bar",
+   :array=>[1, 2, 3],
+   :number=>123,
+   :object=>{:foo=>"bar"},
+   :boolean=>false},
+  :boolean=>true}
```

### Fixed
* Fixed JSON Field Parsing [#96](https://github.com/contentful/contentful.rb/issues/96)

## 0.12.0
### Added
* Added Rate Limit automatic handling

## 0.11.0
### Fixed
* Fixed Locale handling [#98](https://github.com/contentful/contentful.rb/issues/98)

## 0.10.0
### Added
* Added `:fl` parameter to `Asset#image_url` to support `progressive` File Layering
* Added Marshalling methods to `Asset` [#88](https://github.com/contentful/contentful.rb/issues/88)

## Changed
* Changed 503 error message to a less confusing one.

## 0.9.0
### Added
* Added `Contentful::Resource::CustomResource` to automatically map fields to accessors [#79](https://github.com/contentful/contentful.rb/issues/79)
* Added `#raw` to `Contentful::Resource` for easier Marshalling
* Added documentation regarding locales

### Changed
* Changed Documentation Format to YARD

### Fixed
* Fixed Marshalling for Custom Resource Classes [#80](https://github.com/contentful/contentful.rb/issues/80)

## 0.8.0
### Changed
* Unified Locale Handling [#73](https://github.com/contentful/contentful.rb/issues/73)

## 0.7.0
### Added
* Add support for querying a field's `linkType` [#75](https://github.com/contentful/contentful.rb/pull/75)
* Handles multiple locales when requesting with `locale: "*"` [contentful_middleman/#39](https://github.com/contentful-labs/contentful_middleman/issues/39)

### Fixed
* Fix Custom Resource creation parameters [#69](https://github.com/contentful/contentful.rb/issues/69)
* `Sync API` now works with `:raw_mode` enabled [#68](https://github.com/contentful/contentful.rb/issues/68)
* Bugfix for `Field.items` [#76](https://github.com/contentful/contentful.rb/pull/76)

## 0.6.0
### Fixed
* Parse nested locales in `AssetFields` [#66](https://github.com/contentful/contentful.rb/pull/66)

### Other
* Update http.rb dependency to v0.8.0
* Fix typo in service unavailable error message [#61](https://github.com/contentful/contentful.rb/pull/61)
* Enable gzip encoding by default [#62](https://github.com/contentful/contentful.rb/pull/62)

## 0.5.0
### Fixed
* Better handling of 503 responses from the API [#50](https://github.com/contentful/contentful.rb/pull/50)
* Better handling of 429 responses from the API [#51](https://github.com/contentful/contentful.rb/pull/51)

### Added
* `focus` and `fit` to image handling parameters [#44](https://github.com/contentful/contentful.rb/pull/44)

## 0.4.0
### Added
* Proxy support

## 0.3.5
### Added
* Logging of requests

### Fixed
* Cleaner and better error handling

### Other
* Code cleanup
* Remove encoding strings from the source code files

## 0.3.4
### Added
* Optional gzip compression

## 0.3.3
### Fixed
* Fix: handle 503 errors from the API

## 0.3.2
### Added
* Default property to locale, #23

## 0.3.1
### Fixed
* Return nil when a value is not supplied, fixes #18
* Do not parse empty responses

### Other
* Remove CGI dependency for http Gem

## 0.3.0
### Added
* Support Synchronization

## 0.2.0
### Added
* Introduce new :entry_mapping configuration to enable custom Entry classes based on ContentTypes

### Other
* Update HTTP gem dependency to 0.6
* Convert arrays in query values to strings, separated by comma


## 0.1.3
### Fixed
* Better link inclusion processing, prevents "stack level to deep" errors


## 0.1.2
### Fixed
* The way all content types are retrieved


## 0.1.1
### Fixed
* Bug that prevented fields with multiple resources to be parsed correctly

### Other
* Restrict HTTP gem dependency to < 0.6

## 0.1.0
* Initial release.
