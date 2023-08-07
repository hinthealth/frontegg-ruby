module Frontegg
  class Tenant < Resource
    self.base_path = '/tenants/resources/tenants/v1'

    def create(name:, website: nil, logo_url: nil, metadata: {})
      body = { tenantId: resource_id, name:, website:, logoUrl: logo_url, metadata: metadata.to_json }
      client.execute_request(:post, path, body:)
    end

    def update(name:, website: nil, logo_url: nil, metadata: {})
      body = { name:, website:, logoUrl: logo_url, metadata: metadata.to_json }
      client.execute_request(:put, resource_url, body:)
    end

    def retrieve
      client.execute_request(:get, resource_url)
    end

    def delete
      client.execute_request(:delete, resource_url)
    end
  end
end
