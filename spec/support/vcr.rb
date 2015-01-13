require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.ignore_localhost = true
  c.hook_into :webmock
  c.default_cassette_options = { record: :once }
end

def vcr(n, &block)
  VCR.use_cassette(n, &block)
end

def expect_vcr(n, &block)
  expect { VCR.use_cassette(n, &block) }
end
