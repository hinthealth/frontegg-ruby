module Frontegg
  class User < Resource
    self.base_path = '/identity/resources/users/v1'

    def create(email:, name:, tenant_id:, password: nil, metadata: {}, skip_invite_email: true)
      body = { email:, name:, password:, skipInviteEmail: skip_invite_email, metadata: metadata.to_json }
      client.execute_request(:post, resource_url, body:, tenant_id:)
    end

    def add_to_tenant(tenant_id, skip_invite_email: true)
      url = "#{resource_url}/tenant"
      client.execute_request(:post, url, body: { tenantId: tenant_id, skipInviteEmail: skip_invite_email })
    end

    def switch_tenant(tenant_id)
      url = "#{resource_url}/tenant"
      client.execute_request(:put, url, body: { tenantId: tenant_id })
    end

    def update(email: nil, name: nil, metadata: {})
      if name
        client.execute_request(:put, resource_url, body: { name:, metadata: metadata.to_json })
      elsif email
        client.execute_request(:put, "#{resource_url}/email", body: { email: })
      end
    end

    def migrate_existing(email:, name:, password_hash:, metadata:, tenant_id:, mfa_code: nil, role_ids: [])
      body = {
        email:,
        passwordHash: password_hash,
        name:,
        skipInviteEmail: true,
        tenantId: tenant_id,
        metadata: metadata.to_json,
      }
      body[:authenticatorAppMfaSecret] = mfa_code if mfa_code
      body[:roleIds] = role_ids if role_ids.any?
      client.execute_request(:post, 'identity/resources/migrations/v1/local', body:)
    end

    def delete(tenant_id: nil)
      client.execute_request(:delete, resource_url, tenant_id:)
    end

    def expire_sessions(session_id = nil)
      sessions = session_id || 'all'
      path = "/identity/resources/users/sessions/v1/me/#{sessions}"
      client.execute_request(:delete, path, headers: user_header)
    end

    def retrieve(tenant_id: nil)
      if tenant_id
        client.execute_request(:get, resource_url, tenant_id:)
      else
        client.execute_request(:get, "/identity/resources/vendor-only/users/v1/#{resource_id}")
      end
    end

    def make_superuser
      path = "#{resource_url}/superuser"
      client.execute_request(:put, path, body: { superUser: true })
    end

    def verify
      path = "#{resource_url}/verify"
      client.execute_request(:post, path)
    end

    def accept_invitation(user_id:, token:)
      url = "#{self.class.base_path}/invitation/accept"
      client.execute_request(:post, url, body: { userId: user_id, token:})
    end

    def add_role(role_id, tenant_id: nil)
      path = "#{resource_url}/roles"
      client.execute_request(:post, path, body: { roleIds: [role_id]}, tenant_id: tenant_id)
    end

    private

    def user_header
    { 'frontegg-user-id': resource_id }
    end
  end
end
