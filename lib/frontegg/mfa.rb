module Frontegg
  class Mfa < Resource
    self.base_path = '/identity/resources/users/v1/mfa/enroll'

    def create(user_id:)
      client.execute_request(:post, path, headers: user_header(user_id))
    end

    def verify(token, user_id:)
      client.execute_request(:post, "#{path}/verify", body: { token: }, headers: user_header(user_id))
    end

    def reset(user_id:)
      client.execute_request(:post, "/identity/resources/vendor-only/users/v1/#{user_id}/mfa/unenroll")
    end

    def enforce(enforce, device_expiration:, tenant_id: nil)
      path = 'identity/resources/configurations/v1/mfa-policy'
      enforce_type = enforce ? 'Force' : 'DontForce'
      body = { enforceMFAType: enforce_type, allowRememberMyDevice: true, mfaDeviceExpiration: device_expiration }
      client.execute_request(:put, path, body:, tenant_id:)
    end

    private

    def user_header(user_id)
      { 'frontegg-user-id': user_id }
    end
  end
end
