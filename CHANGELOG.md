# Change Log
## Unreleased
### Fixed
* Fix Custom Resource creation parameters [#69](https://github.com/contentful/contentful.rb/issues/69)
* `Sync API` now works with `:raw_mode` enabled [#68](https://github.com/contentful/contentful.rb/issues/68)

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
