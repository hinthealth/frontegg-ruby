require 'bundler/setup'
require 'webmock/rspec'
require_relative './../lib/frontegg'
require_relative './support/mock_frontegg'

WebMock.disable_net_connect!(allow_localhost: true)

# Frontegg.configure do |config|
#   config.env = :dev
#   config.platform_customer_id = '1234'
#   config.publishable_key = 'key_1234'
# end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do |_example|
    MockFrontegg.init(self)
  end
  #
  # config.after(:each) do |example|
  #   Frontegg::Testing.disable if example.metadata[:mock_paystand]
  # end
end
