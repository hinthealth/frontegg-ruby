require 'spec_helper'

RSpec.describe Frontegg::Tenant, mock_frontegg: true do
  let(:frontegg_url) { 'https://api.frontegg.com' }
  let(:tenant_id) { 'tenant_123' }
  let(:tenant_resource) { Frontegg::Tenant.new(tenant_id) }

  describe '#create' do
    subject(:response) { tenant_resource.create(name: 'example') }

    before do
      stub_request(:post, "#{frontegg_url}/tenants/resources/tenants/v1")
        .with(body: { tenantId: tenant_id, name: 'example', website: nil, logoUrl: nil, isReseller: false,
                      metadata: {}.to_json })
        .to_return(status: 200)
    end

    it 'creates tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#update' do
    subject(:response) { tenant_resource.update(name: 'another name') }

    before do
      stub_request(:put, "#{frontegg_url}/tenants/resources/tenants/v1/#{tenant_id}")
        .with(body: { name: 'another name', website: nil, logoUrl: nil, isReseller: false, metadata: {}.to_json })
        .to_return(status: 200)
    end

    it 'updates tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#retrieve' do
    subject(:response) { tenant_resource.retrieve }

    before do
      stub_request(:get, "#{frontegg_url}/tenants/resources/tenants/v1/#{tenant_id}")
        .to_return(status: 200)
    end

    it 'retrieves tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#list' do
    subject(:response) { tenant_resource.list }

    before do
      stub_request(:get, "#{frontegg_url}/tenants/resources/tenants/v2?_filter&_limit")
        .to_return(status: 200)
    end

    it 'retrieves tenants successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#add_parent_tenant' do
    subject(:response) { tenant_resource.add_parent_tenant(parent_id: 'parent_id') }

    before do
      stub_request(:post, "#{frontegg_url}/tenants/resources/hierarchy/v1")
        .to_return(status: 200)
    end

    it 'adds parent tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#remove_parent_tenant' do
    subject(:response) { tenant_resource.remove_parent_tenant(parent_id: 'parent_id') }

    before do
      stub_request(:delete, "#{frontegg_url}/tenants/resources/hierarchy/v1")
        .to_return(status: 200)
    end

    it 'removes parent tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#create_invite' do
    let(:email) { 'test@example.com' }
    let(:name) { 'Test User' }
    let(:role_ids) { ['role_1', 'role_2'] }
    let(:metadata) { { custom_field: 'custom_value' } }
    let(:expected_body) do
      {
        tenantId: tenant_id,
        email: email,
        name: name,
        roleIds: role_ids,
        metadata: metadata
      }
    end

    subject(:response) { tenant_resource.create_invite(email: email, name: name, role_ids: role_ids, metadata: metadata) }

    context 'when invitation is created successfully' do
      before do
        stub_request(:post, "#{frontegg_url}/identity/resources/invitations/v1/tenant")
          .with(body: expected_body)
          .to_return(status: 201, body: { id: 'invite_123' }.to_json)
      end

      it 'returns a successful response' do
        expect(response.status).to eq 201
      end

      it 'calls the API with the correct parameters' do
        response # Trigger the request
        expect(
          a_request(:post, "#{frontegg_url}/identity/resources/invitations/v1/tenant")
          .with(body: expected_body)
        ).to have_been_made.once
      end
    end

    context 'when API returns an error (e.g., invalid input)' do
      before do
        stub_request(:post, "#{frontegg_url}/identity/resources/invitations/v1/tenant")
          .with(body: expected_body)
          .to_return(status: 400, body: { error: 'Invalid input' }.to_json)
      end

      it 'returns an error response' do
        expect(response.status).to eq 400
      end
    end

    context 'when API returns a server error' do
      before do
        stub_request(:post, "#{frontegg_url}/identity/resources/invitations/v1/tenant")
          .with(body: expected_body)
          .to_return(status: 500, body: { error: 'Server error' }.to_json)
      end

      it 'returns an error response' do
        expect(response.status).to eq 500
      end
    end
  end
end
