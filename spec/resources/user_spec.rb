require 'spec_helper'

RSpec.describe Frontegg::User, mock_frontegg: true do
  let(:frontegg_url) { 'https://api.frontegg.com' }
  let(:user_id) { 'idp_123' }
  let(:tenant_id) { 'tenant_123' }
  let(:user_resource) { Frontegg::User.new(user_id) }

  describe '#switch_tenant' do
    subject(:response) { user_resource.switch_tenant(tenant_id) }

    before do
      stub_request(:put, "#{frontegg_url}/identity/resources/users/v1/#{user_id}/tenant")
        .to_return(status: 200)
    end

    it 'switches tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#make_superuser' do
    subject(:response) { user_resource.make_superuser }

    before do
      stub_request(:put, "#{frontegg_url}/identity/resources/users/v1/#{user_id}/superuser")
        .to_return(status: 200)
    end

    it 'makes user super user successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#retrieve' do
    subject(:response) { user_resource.retrieve(tenant_id:) }

    before do
      stub_request(:get, "#{frontegg_url}/identity/resources/users/v1/#{user_id}")
        .to_return(status: 200)
    end

    it 'retrieves user successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#delete' do
    subject(:response) { user_resource.delete }

    before do
      stub_request(:delete, "#{frontegg_url}/identity/resources/users/v1/#{user_id}")
        .to_return(status: 200)
    end

    it 'deletes user successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '.migrate_existing' do
    subject(:response) do
      Frontegg::User.new.migrate_existing(
        email: 'example@example.com',
        name: 'John Doe',
        password_hash: 'password_hash',
        metadata: {},
        tenant_id: tenant_id
      )
    end

    before do
      stub_request(:post, "#{frontegg_url}/identity/resources/migrations/v1/local")
        .to_return(status: 200, body: { id: user_id }.to_json)
    end

    it 'migrates user successfully' do
      expect(response.status).to eq 200
      expect(response.body).to include('id')
    end
  end
end
