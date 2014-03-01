# -*- encoding: utf-8 -*-

require File.expand_path('../lib/contentful/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "contentful"
  gem.version       = Contentful::VERSION
  gem.summary       = 'contentful'
  # gem.description   = 'contentul'
  gem.license       = "MIT"
  gem.authors       = ["contentful (Jan Lelis)"]
  # gem.email         = ""
  gem.homepage      = "https://github.com/contentful/contentful.rb"

  gem.files         = Dir['{**/}{.*,*}'].select { |path| File.file?(path) && !path.start_with?("pkg") }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
