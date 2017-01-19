require 'contentful'

# You can define your own custom classes that inherit from Contentful::Entry.
# This allows you to define custom behaviour, for example, in this case, we want
# the :country field to act as a Contentful::Locale
class MyResource < Contentful::Entry
  def country(locale = nil)
    @country ||= Contentful::Locale.new(fields(locale)[:country])
  end
end

res = MyResource.new('fields' => {
  'some' => 'value',
  'age' => '25',
  'country' => { 'code' => 'de', 'name' => 'Deutschland' },
  'unknown_property' => 'ignored'
})

p res.some # => "value"
p res.age # => 25
p res.country # #<Contentful::Locale: ...
p res.unknown_property # NoMethodError

# To then have it mapped automatically from the client,
# upon client instantiation, you set the :entry_mapping for your ContentType.

client = Contentful::Client.new(
  space: 'your_space_id',
  access_token: 'your_access_token',
  entry_mapping: {
    'myResource' => MyResource
  }
)

# We request the entries, entries of the 'myResource` content type,
# will return MyResource class objects, while others will remain Contentful::Entry.
client.entries.each { |e| puts e }
# => <Contentful::Entry[other_content_type] id='foobar'>
# => <MyResource[myResource] id='baz'>
