module Frontegg
  class Resource
    def initialize(resource_id = nil)
      @resource_id = resource_id
      @client = Frontegg.client
    end

    class << self
      attr_accessor :base_path
    end

    protected

    attr_reader :client, :resource_id

    def path
      self.class.base_path
    end

    def resource_url
      "#{path}/#{resource_id}"
    end
  end
end
