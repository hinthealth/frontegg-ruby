require 'frontegg/config'
require 'frontegg/resource'
require 'frontegg/client'
require 'frontegg/invalid_request_error'
require 'frontegg/mfa'
require 'frontegg/name_error'
require 'frontegg/not_found_error'
require 'frontegg/password'
require 'frontegg/tenant'
require 'frontegg/unauthenticated_error'
require 'frontegg/user'

module Frontegg
  def self.config
    @config ||= Config.new
  end

  def self.reset
    @config = Config.new
    @client = Client.new
  end

  def self.configure
    yield(config)
  end

  def self.client
    @client ||= Client.new
  end
end
