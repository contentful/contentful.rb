# Change Log

## Unreleased

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
