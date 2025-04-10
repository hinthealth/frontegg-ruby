module Frontegg
  class User < Resource
    self.base_path = '/identity/resources/users/v1'

    def create(email:, name:, tenant_id:, **params)
      body = build_user_params(email: email, name: name, metadata: params[:metadata], role_ids: params[:role_ids])
      body[:password] = params[:password] if params[:password]
      body[:skipInviteEmail] = params.fetch(:skip_invite_email, true)
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

    def migrate_existing(email:, name:, password_hash:, tenant_id:, **params)
      body = build_user_params(email: email, name: name, metadata: params[:metadata], role_ids: params[:role_ids])
      body[:passwordHash] = password_hash
      body[:tenantId] = tenant_id
      body[:authenticatorAppMfaSecret] = params[:mfa_code] if params[:mfa_code]
      body[:skipInviteEmail] = true
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

    def build_user_params(email:, name:, metadata: {}, role_ids: [])
      body = {
        email: email,
        name: name,
        metadata: metadata.to_json
      }
      body[:roleIds] = role_ids if role_ids&.any?
      body
    end

    def user_header
    { 'frontegg-user-id': resource_id }
    end
  end
end
