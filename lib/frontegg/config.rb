module Frontegg
  class Config
    attr_accessor :client_id, :api_key, :log_enabled

    def initialize
      @client_id = nil
      @api_key = nil
      @log_enabled = false
    end
  end
end
