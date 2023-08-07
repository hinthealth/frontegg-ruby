require 'jwt'

module MockFrontegg
  extend self

  def init(rspec, expiration: Time.now.to_i + 5 * 3600, status: 200, body: nil )
    base_url = 'https://api.frontegg.com'
    payload = { data: 'data', exp: expiration }
    token = JWT.encode(payload, nil, 'none')
    body ||= { token: }.to_json
    headers = { content_type: 'application/json' }
    rspec.stub_request(:post, "#{base_url}/auth/vendor/").to_return(status:, body:, headers:)
  end
end
