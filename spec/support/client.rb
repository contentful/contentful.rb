def create_client(options = {})
  Contentful::Client.new({
    space: 'cfexampleapi',
    access_token: 'b4c0n73n7fu1',
  }.merge(options))
end
