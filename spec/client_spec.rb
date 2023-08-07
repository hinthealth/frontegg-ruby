require 'spec_helper'

RSpec.describe Frontegg::Client do
  let(:frontegg_url) { 'https://api.frontegg.com' }
  let(:client) { Frontegg::Client.new }
  let(:path) { '/tenants/resources/tenants/v1' }

  describe '#execute_request' do
    subject(:response) { client.execute_request(:get, path) }

    before do
      stub_request(:get, "#{frontegg_url}#{path}").to_return(status: 200)
    end

    context 'when the token is valid' do
      before do
        MockFrontegg.init(self)
      end

      it 'authenticates the request' do
        response
        assert_requested(
          :post,
          "#{frontegg_url}/auth/vendor/",
          body: { clientId: Frontegg.config.client_id, secret: Frontegg.config.api_key }
        )
      end

      it 'makes a succesful request' do
        expect(response.status).to eq 200
      end

      context 'when the secret is missing' do
        let(:previous_secret) { Frontegg.config.api_key }
        before do
          previous_secret
          Frontegg.config.api_key = nil
          MockFrontegg.init(self, status: 401, body: { message: 'Secret cannot be empty' }.to_json)
        end

        it 'fails with unauthenticated' do
          expect { client }.to raise_error(Frontegg::UnauthenticatedError)
        end

        after do
          Frontegg.config.api_key = previous_secret
        end
      end

      context 'when the route is incorrect' do
        let(:path) { '/tenants/resources/tena/v1' }

        before do
          stub_request(:get, "#{frontegg_url}#{path}").to_return(status: 404)
        end

        it 'fails with not found' do
          expect { response }.to raise_error(Frontegg::NotFoundError)
        end
      end
    end

    context 'when the token is expired' do
      before do
        MockFrontegg.init(self, expiration: (Time.now - (5 * 60)).to_i)
      end

      it 'makes a succesful request' do
        expect(response.status).to eq 200
      end

      it 'refreshes the token' do
        expect_any_instance_of(Frontegg::Client).to receive(:retrieve_token).twice.and_call_original
        subject
      end
    end
  end
end
