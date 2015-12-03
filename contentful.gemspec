require File.expand_path('../lib/contentful/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'contentful'
  gem.version       = Contentful::VERSION
  gem.summary       = 'contentful'
  gem.description   = 'Ruby client for the https://www.contentful.com Content Delivery API'
  gem.license       = 'MIT'
  gem.authors       = ['Contentful GmbH (Jan Lelis)', 'Contentful GmbH (Andreas Tiefenthaler)']
  gem.email         = 'rubygems@contentful.com'
  gem.homepage      = 'https://github.com/contentful/contentful.rb'

  gem.files         = Dir['{**/}{.*,*}'].select { |path| File.file?(path) && !path.start_with?('pkg') }
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_dependency 'http', '~> 0.8'
  gem.add_dependency 'multi_json', '~> 1'

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rspec', '~> 2'
  gem.add_development_dependency 'rr'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'webmock', '~> 1', '>= 1.17.3'
end
