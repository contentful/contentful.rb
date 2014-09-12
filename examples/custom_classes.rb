# Contentful resource classes are just plain Ruby classes that include the
# Contentful::Resource module.
#
# You can then define properties of the class. This will create a getter method
# with this name. You can optionally pass a type identifier (Symbol or Class).
#
# Classes will be instantiated for the properties,
# Symbols will be looked up in Contentful::Resource::COERCIONS

require 'contentful'

class MyResource
  include Contentful::Resource

  property :some
  property :age, :integer
  property :country, Contentful::Locale
end

res = MyResource.new(
  'some' => 'value',
  'age' => '25',
  'country' => { 'code' => 'de', 'name' => 'Deutschland' },
  'unknown_property' => 'ignored'
)

p res.some # => "value"
p res.age # => 25
p res.country # #<Contentful::Locale: ...
p res.unknown_property # NoMethodError

# Another possibility to create customized resources is to just inherit from an
# existing one:

class MyBetterArray < Contentful::Array
  # e.g. define more methods that you need
  def last
    items.last
  end
end

# Read further in examples/resource_mapping.rb
