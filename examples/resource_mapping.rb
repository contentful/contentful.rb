# Using the :resource_mapping configuration, you can register your own classes to be used
# for the results from contentful.
#
# The key of the resource_mapping hash defines the resource type (object["sys"]["type"]) and the value is:
# - the Class to use
# - a Proc, that returns the Class to use
# - a Symbol for a method of the ResourceBuilder object

require 'contentful'

class MyBetterArray < Contentful::Array
  # e.g. define more methods that you need
  def last
    items.last
  end
end

client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
  resource_mapping: {
    'Array' => MyBetterArray,
    'Asset' => ->(_json_object)do
      # might return different class if some criteria is matched
      Contentful::Asset
    end,
  }
)

assets = client.assets
p assets.class # => MyBetterArray
p assets.last # => #<Contentful::Asset ...
