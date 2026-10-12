require 'faraday'
require 'jwt'

module Frontegg
  class Client
    BASE_URL = 'https://api.frontegg.com'.freeze

    def initialize
      @token = retrieve_token
    end

    def execute_request(method, path, headers: {}, body: nil, params: nil, tenant_id: nil)
      fail NameError unless %i[post put get delete].include?(method)

      @token = retrieve_token if token_expired?

      connection.public_send(method) do |request|
        request.url path
        request.headers = build_headers(headers, tenant_id)
        request.body = JSON.generate(body) if body
        request.params = params if params
      end.tap(&check_response)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      raise Faraday::TimeoutError
    rescue Faraday::ParsingError => e
      Raven.capture_exception(e, extra: { token: }) # Remove me on 2023-03-01 if no errors are reported
    end

    private

    attr_reader :api_key, :client_id, :token

    def connection
      Faraday.new(url: BASE_URL, ssl: { verify: true }) do |connection|
        connection.request :json
        connection.response :json
        connection.response :logger if Frontegg.config.log_enabled
        connection.adapter Faraday.default_adapter
      end
    end

    def retrieve_token
      credentials = { clientId: Frontegg.config.client_id, secret: Frontegg.config.api_key }
      response = connection.post('/auth/vendor/', JSON.generate(credentials)).tap(&check_response)
      return response.body['token'] if response.success? && response.body['token']
    end

    def build_headers(headers, tenant_id)
      headers['Content-Type'] = 'application/json'
      headers['frontegg-tenant-id'] = tenant_id if tenant_id
      headers['Authorization'] = "Bearer #{token}" if token
      headers
    end

    def check_response
      ->(response) do
        fail Frontegg::NotFoundError, not_found_message(response) if response.status.eql?(404)
        fail Frontegg::UnauthenticatedError, parse_error(response) if response.status.eql?(401)
        fail Frontegg::TooManyRequestsError, parse_error(response) if response.status.eql?(429)
        fail Frontegg::InvalidRequestError, parse_error(response) unless response.success?
      end
    end

    # A 404 body is usually empty, so the request is the only thing that says
    # what was not found - and the tenant header is what scoped the lookup.
    def not_found_message(response)
      tenant_id = response.env.request_headers['frontegg-tenant-id']
      error = parse_error(response).to_s

      [
        "#{response.env.method.to_s.upcase} #{response.env.url.path}",
        ("tenant #{tenant_id}" if tenant_id),
        (error unless error.empty?),
      ].compact.join(', ')
    end

    def parse_error(response)
      body = response.body

      return body unless body.is_a?(Hash)

      body['errors']&.first || body
    end

    def token_expired?
      token && Time.now.to_i > JWT.decode(token, nil, false).first['exp']
    end
  end
end
