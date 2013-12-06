require File.expand_path('../../offers', __FILE__)
require 'rspec'
require 'rack/test'
require 'capybara/rspec'
require 'timecop'

set :environment,  :test
set :run,          false
set :raise_errors, true

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  Capybara.app = app

  config.before(:each) do
    Timecop.return
  end
end
