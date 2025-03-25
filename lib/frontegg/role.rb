module Frontegg
  class Role < Resource
    self.base_path = '/identity/resources/roles/v1'

    def find_by_key(key, tenant_id: nil)
      response = client.execute_request(:get, self.class.base_path, tenant_id:)
      response.body.find { |role| role['key'] == key }
    end
  end
end
