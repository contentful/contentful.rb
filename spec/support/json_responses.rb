require 'multi_json'

def raw_fixture(which, status = 200, _as_json = false)
  object = Object.new
  stub(object).status { status }
  stub(object).headers { {} }
  stub(object).to_s { File.read File.dirname(__FILE__) + "/../fixtures/json_responses/#{which}.json" }

  object
end

def json_fixture(which, _as_json = false)
  MultiJson.load(
    File.read File.dirname(__FILE__) + "/../fixtures/json_responses/#{which}.json"
  )
end
