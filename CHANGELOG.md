### 0.3.4
* add optional gzip compression

### 0.3.3
* Fix: handle 503 errors from the api

### 0.3.2
* add default property to locale, #23

### 0.3.1
* return nil when a value is not supplied, fixes #18
* do not parse empty responses
* remove CGI dependency for http gem

### 0.3.0

* Support Synchronization


### 0.2.0

* Introduce new :entry_mapping configuration to enable custom Entry classes based on ContentTypes
* Update HTTP gem dependency to 0.6
* Convert arrays in query values to strings, separated by comma


### 0.1.3

* Better link inclusion processing, prevent "stack level to deep" errors


### 0.1.2

* Fix the way all content types are retrieved


### 0.1.1

* Fix a bug that prevented fields with multiple resources to be parsed correctly
* Restrict HTTP gem dependency to < 0.6


### 0.1.0

* Initial release.
