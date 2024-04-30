module Frontegg
  class Hierarchy < Resource
    self.base_path = '/tenants/resources/hierarchy/v1'

    def create(parent_id:)
      body = { childTenantId: resource_id, parentTenantId: parent_id }
      client.execute_request(:post, path, body:)
    end
  end
end
