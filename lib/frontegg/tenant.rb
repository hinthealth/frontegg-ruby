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
      client.execute_request(:get, path, params: { _filter: filter, _limit: limit })
    end

    def add_parent_tenant(parent_id:)
      path = '/tenants/resources/hierarchy/v1'
      body = { childTenantId: resource_id, parentTenantId: parent_id }
      client.execute_request(:post, path, body:)
    end

    def remove_parent_tenant(parent_id:)
      path = '/tenants/resources/hierarchy/v1'
      body = { childTenantId: resource_id, parentTenantId: parent_id }
      client.execute_request(:delete, path, body:)
    end

    def get_timeout(tenant_id)
      path = "/identity/resources/configurations/sessions/v1"
      client.execute_request(:get, path, tenant_id:)
    end

    def configure_timeout(tenant_id, time)
      path = "/identity/resources/configurations/sessions/v1"
      client.execute_request(:post, path, body: { sessionIdleTimeoutConfiguration: { isActive: false, timeout: time} }, tenant_id: )
    end

    def create_invite(email:, name:, role_ids:, metadata: {})
      path = '/identity/resources/invitations/v1/tenant'
      body = {
        tenantId: resource_id,
        email: email,
        name: name,
        roleIds: role_ids,
        metadata: metadata
      }
      client.execute_request(:post, path, body: body)
    end
  end
end
