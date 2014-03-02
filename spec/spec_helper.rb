require 'rspec'
require 'contentful'
require 'securerandom'
require 'debugging/all'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each{ |f| require f }