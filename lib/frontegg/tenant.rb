module Frontegg
  class Tenant < Resource
    self.base_path = '/tenants/resources/tenants/v1'

    def create(name:, website: nil, logo_url: nil, is_reseller: false, metadata: {})
      body = { tenantId: resource_id, name:, website:, logoUrl: logo_url, isReseller: is_reseller, metadata: metadata.to_json }
      client.execute_request(:post, path, body:)
    end

    def update(name:, website: nil, logo_url: nil, is_reseller: false, metadata: {})
      body = { name:, website:, logoUrl: logo_url, isReseller: is_reseller, metadata: metadata.to_json }
      client.execute_request(:put, resource_url, body:)
    end

    def retrieve
      client.execute_request(:get, resource_url)
    end

    def delete
      client.execute_request(:delete, resource_url)
    end

    def list(filter: nil, limit: nil)
			path = "/tenants/resources/tenants/v2"
      client.execute_request(:get, path, params: { _filter: filter, _limit: limit } )
    end
  end
end
