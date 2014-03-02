require 'multi_json'

def raw_fixture(which, as_json = false)
  File.read File.dirname(__FILE__) + "/../fixtures/json_responses/#{which}.json"
end

def json_fixture(which, as_json = false)
  MultiJson.load(
    File.read File.dirname(__FILE__) + "/../fixtures/json_responses/#{which}.json"
  )
end