$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'poor_man_search'
require 'coveralls'
Coveralls.wear!

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
  end
end

# load spec/support/**/*.rb
Dir["#{File.dirname(__FILE__)}/support/*.rb"].each {|f| require f}
