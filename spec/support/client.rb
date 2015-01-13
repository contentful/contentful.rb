def create_client(options = {})
  Contentful::Client.new({
    space: 'cfexampleapi',
  }.merge(options))
end
