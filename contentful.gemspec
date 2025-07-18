require File.expand_path('../lib/contentful/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'contentful'
  gem.version       = Contentful::VERSION
  gem.summary       = 'contentful'
  gem.description   = 'Ruby client for the https://www.contentful.com Content Delivery API'
  gem.license       = 'MIT'
  gem.authors       = ['Contentful GmbH (Jan Lelis)', 'Contentful GmbH (Andreas Tiefenthaler)', 'Contentful GmbH (David Litvak Bruno)']
  gem.email         = 'rubygems@contentful.com'
  gem.homepage      = 'https://github.com/contentful/contentful.rb'

  gem.files         = Dir["lib/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md"]

  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  if RUBY_VERSION.start_with?('1.')
    gem.add_dependency 'http', '> 0.8', '< 2'
    gem.add_dependency 'json', '~> 2.7'
    gem.add_development_dependency'term-ansicolor', '~> 1.3.0'
    gem.add_development_dependency 'public_suffix', '< 1.5'
  else
    gem.add_dependency 'http', '> 0.8', '< 6.0'
  end

  gem.add_dependency 'multi_json', '~> 1.15'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake', '>= 12.3.3'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-rubocop'
  gem.add_development_dependency 'guard-yard'
  gem.add_development_dependency 'rubocop', '~> 1.60.2'
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'rr'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'tins', '~> 1.6.0'
end
