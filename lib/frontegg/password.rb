module Frontegg
  class Password < Resource
    self.base_path = '/identity/resources/users/v1'

    def update(user_id:, password:, new_password:)
      body = { password:, newPassword: new_password }
      client.execute_request(:post, "#{path}/passwords/change", body:, headers: user_header(user_id))
    end

    def create_reset_token(user_id:)
      client.execute_request(:post, "#{path}/#{user_id}/links/generate-password-reset-token")
    end

    def reset_with_token(user_id:, token:, password:)
      body = { userId: user_id, token:, password: }
      client.execute_request(:post, "#{path}/passwords/reset/verify", body:)
    end

    private

    def user_header(user_id)
      { 'frontegg-user-id': user_id }
    end
  end
end
